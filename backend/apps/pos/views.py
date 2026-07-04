"""POS views."""
from common.permissions import HasMemberToken, IsTenantUser
from common.token_utils import get_member_from_request
from django.db import transaction
from django.utils import timezone
from rest_framework import viewsets
from rest_framework.exceptions import AuthenticationFailed
from rest_framework.filters import OrderingFilter
from rest_framework.permissions import IsAuthenticated

from apps.members.models import Member as MemberModel
from .models import Order
from .serializers import OrderCreateSerializer, OrderDetailSerializer, OrderListSerializer


def _get_member_from_token(request):
    """Extract member from Authorization: Token header, or return None."""
    return get_member_from_request(request)


class OrderViewSet(viewsets.ModelViewSet):
    filter_backends = [OrderingFilter]
    ordering_fields = ['paid_at', 'total_amount']

    def get_permissions(self):
        if self.action == 'create':
            # Allow both admin JWT and member token (member self-checkout)
            return [IsTenantUser(), (IsAuthenticated | HasMemberToken)()]
        if self.action == 'list':
            return [IsTenantUser(), (IsAuthenticated | HasMemberToken)()]
        return [IsAuthenticated(), IsTenantUser()]

    def get_queryset(self):
        qs = Order.objects.filter(tenant=self.request.tenant).prefetch_related('items')
        # If customer token present, filter to that member's orders only
        member = _get_member_from_token(self.request)
        if member:
            qs = qs.filter(member=member)
        return qs

    def get_serializer_class(self):
        if self.action == 'create':
            return OrderCreateSerializer
        if self.action in ('list',):
            return OrderListSerializer
        return OrderDetailSerializer

    @transaction.atomic
    def perform_create(self, serializer):
        # Validate member token if provided — reject invalid tokens
        auth = self.request.headers.get('Authorization', '')
        member = None
        cashier = self.request.user if self.request.user.is_authenticated else None
        if auth.startswith('Token '):
            member = _get_member_from_token(self.request)
            if not member:
                raise AuthenticationFailed('无效的会员令牌')

        order = serializer.save(cashier=cashier, tenant=self.request.tenant, member=member)

        # Validate and apply coupon if provided
        coupon_id = serializer.validated_data.get('coupon_id')
        if coupon_id and member:
            from apps.coupons.models import Coupon, MemberCoupon
            from apps.coupons.services import coupon_service
            try:
                coupon = Coupon.objects.get(id=coupon_id, tenant=self.request.tenant)
            except Coupon.DoesNotExist:
                raise AuthenticationFailed('优惠券不存在')

            result = coupon_service.validate(coupon, member, order.items.all())
            if not result.valid:
                raise AuthenticationFailed(result.reason)

            # Mark coupon as used
            MemberCoupon.objects.filter(member=member, coupon=coupon, used=False).update(
                used=True, used_at=timezone.now()
            )

        # ponytail: award points and update total_spent for non-member_card payments
        if member and order.payment_method != 'member_card':
            member_model = MemberModel.objects.select_for_update().get(pk=member.pk)
            member_model.total_spent += order.paid_amount
            member_model.points += int(round(order.paid_amount))
            member_model.save(update_fields=['total_spent', 'points'])
