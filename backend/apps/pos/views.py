"""POS views."""
from decimal import Decimal

from common.permissions import HasMemberToken, IsAdminOrManager, IsAuthenticatedCashierOrMember, IsTenantUser
from common.token_utils import get_member_from_request
from django.db import transaction
from django.db.models import F
from django.utils import timezone
from rest_framework import status, viewsets
from rest_framework.exceptions import AuthenticationFailed, ValidationError
from rest_framework.filters import OrderingFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.members.models import Member as MemberModel
from .models import Order
from .serializers import OrderCreateSerializer, OrderDetailSerializer, OrderListSerializer


def _resolve_member(request):
    """Return Member from `Authorization: Token <hash>` header, or None.

    A presented-but-invalid token is rejected hard (mirrors the old behaviour);
    absence of the header just means it's a staff/cashier order.
    """
    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Token '):
        return None
    member = get_member_from_request(request)
    if not member:
        raise AuthenticationFailed('无效的会员令牌')
    return member


def _apply_coupon(order, member, coupon_id, tenant):
    """Validate the coupon against this order, mark it used, return discount.

    Returns Decimal('0') when no coupon is supplied. Raises ValidationError on
    any validation failure — the caller is already inside @transaction.atomic
    so the whole order rolls back, including the stock deductions.

    Discount basis:
      - Universal coupon: whole cart subtotal
      - Category coupon: only eligible items' subtotal (real-supermarket logic)
      - Percent: eligible × value/100
      - Fixed: min(coupon.discount_value, eligible) — never pay user to shop
    """
    if not coupon_id or not member:
        return Decimal('0')

    from apps.coupons.models import Coupon, MemberCoupon
    from apps.coupons.services import coupon_service
    try:
        coupon = Coupon.objects.get(id=coupon_id, tenant=tenant)
    except Coupon.DoesNotExist:
        raise ValidationError('优惠券不存在')

    result = coupon_service.validate(coupon, member, order)
    if not result.valid:
        raise ValidationError(result.reason)

    MemberCoupon.objects.filter(member=member, coupon=coupon, used=False).update(
        used=True, used_at=timezone.now()
    )

    eligible = result.eligible_amount
    if coupon.discount_type == Coupon.DiscountType.PERCENT:
        return (eligible * coupon.discount_value / Decimal('100')).quantize(Decimal('0.01'))
    # Fixed: cap at eligible so a ¥50 coupon can't discount a ¥30 eligible basket to -¥20.
    return min(coupon.discount_value, eligible)


def _charge_member_balance(order, member):
    """Deduct paid_amount from member balance, award points, update total_spent."""
    if not member:
        raise ValidationError('会员卡支付需要会员登录')
    member = MemberModel.objects.select_for_update().get(pk=member.pk)
    if member.balance < order.paid_amount:
        raise ValidationError(
            f'会员余额不足：当前 ¥{member.balance}，需支付 ¥{order.paid_amount}'
        )
    member.balance -= order.paid_amount
    member.total_spent += order.paid_amount
    member.points += int(round(order.paid_amount))  # ponytail: 1 point per yuan
    member.save(update_fields=['balance', 'total_spent', 'points'])


class OrderViewSet(viewsets.ModelViewSet):
    filter_backends = [OrderingFilter]
    ordering_fields = ['paid_at', 'total_amount']

    def get_permissions(self):
        # ponytail: cashier operations allowed, member token for self-orders, admin full access
        if self.action in ('create', 'list', 'retrieve'):
            return [IsTenantUser(), IsAuthenticatedCashierOrMember()]
        return [IsAuthenticated(), IsTenantUser(), IsAdminOrManager()]

    def get_queryset(self):
        qs = Order.objects.filter(tenant=self.request.tenant).prefetch_related('items')
        member = _resolve_member(self.request)
        if member:
            qs = qs.filter(member=member)
        return qs

    def get_serializer_class(self):
        if self.action == 'create':
            return OrderCreateSerializer
        if self.action == 'list':
            return OrderListSerializer
        return OrderDetailSerializer

    @transaction.atomic
    def perform_create(self, serializer):
        request = self.request
        member = _resolve_member(request)

        # serializer.create already: locked SKUs, recomputed amounts, deducted
        # stock, and stashed the coupon id.
        order = serializer.save(member=member)

        discount = _apply_coupon(order, member, serializer.validated_data.get('coupon_id'), request.tenant)
        if discount > 0:
            order.discount_amount = discount
            order.paid_amount = order.total_amount - discount
            order.save(update_fields=['discount_amount', 'paid_amount'])

        if order.payment_method == 'member_card':
            # Balance deduction + points all happen atomically with the order.
            _charge_member_balance(order, member)
        elif member:
            # Non-member-card payment: still reward points & total_spent.
            MemberModel.objects.select_for_update().filter(pk=member.pk).update(
                total_spent=F('total_spent') + order.paid_amount,
                points=F('points') + int(round(order.paid_amount)),
            )

    def create(self, request, *args, **kwargs):
        """Override to return OrderDetailSerializer (includes member info)."""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        detail = OrderDetailSerializer(serializer.instance, context={'request': request})
        return Response(detail.data, status=status.HTTP_201_CREATED)
