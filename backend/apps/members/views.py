"""Member views — full CRUD + recharge."""
from common.permissions import HasMemberToken, IsAdminOrManager, IsCashier, IsTenantUser
from common.token_utils import get_member_from_request
from django.db import transaction
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Member
from .serializers import MemberSerializer, MemberWriteSerializer


class MemberViewSet(viewsets.ModelViewSet):
    serializer_class = MemberSerializer
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['name', 'phone', 'card_no']
    ordering_fields = ['name', 'points', 'total_spent', 'created_at']

    # ponytail: cashier read-only, manager/admin full
    def get_permissions(self):
        if self.action in ('list', 'retrieve'):
            return [IsAuthenticated(), IsTenantUser(), IsCashier()]
        return [IsAuthenticated(), IsTenantUser(), IsAdminOrManager()]

    def get_queryset(self):
        return Member.objects.filter(tenant=self.request.tenant)

    def get_serializer_class(self):
        if self.action in ('create', 'update', 'partial_update'):
            return MemberWriteSerializer
        return MemberSerializer

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)

    @action(detail=False, methods=['post'], url_path='recharge', permission_classes=[IsTenantUser, HasMemberToken])
    def recharge(self, request, **kwargs):
        """POST /{slug}/members/recharge/ — member self-recharge via token auth."""
        member = get_member_from_request(request)
        if not member:
            return Response({'detail': '未提供认证令牌或令牌无效'}, status=status.HTTP_401_UNAUTHORIZED)

        amount = request.data.get('amount', 0)
        bonus = request.data.get('bonus', 0)
        try:
            amount = int(amount) if amount else 0
            bonus = int(bonus) if bonus else 0
        except (ValueError, TypeError):
            return Response({'detail': '金额无效'}, status=status.HTTP_400_BAD_REQUEST)

        if amount <= 0:
            return Response({'detail': '充值金额必须大于0'}, status=status.HTTP_400_BAD_REQUEST)

        if bonus < 0:
            return Response({'detail': '赠送金额不能为负'}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            member = Member.objects.select_for_update().get(pk=member.pk)
            member.balance += amount + bonus
            member.save(update_fields=['balance'])

        return Response({
            'balance': str(member.balance),
            'amount': amount,
            'bonus': bonus,
            'total': amount + bonus,
        })

    @action(detail=False, methods=['get'], url_path='coupons', permission_classes=[IsTenantUser, HasMemberToken])
    def coupons(self, request, **kwargs):
        """GET /{slug}/members/coupons/ — member's owned coupons.

        Also returns `is_new_member` so the checkout page can show/hide the
        新人专享 coupon without an extra round-trip.
        """
        from apps.coupons.models import MemberCoupon
        from apps.coupons.serializers import MemberCouponSerializer
        from apps.pos.models import Order

        member = get_member_from_request(request)
        if not member:
            return Response({'results': [], 'count': 0, 'is_new_member': False})

        qs = MemberCoupon.objects.filter(
            tenant=request.tenant, member=member,
        ).select_related('coupon').order_by('-created_at')

        is_new_member = not Order.objects.filter(member=member, tenant=request.tenant).exists()

        return Response({
            'results': MemberCouponSerializer(qs, many=True).data,
            'count': qs.count(),
            'is_new_member': is_new_member,
        })

    @action(detail=False, methods=['post'], url_path='deduct-balance', permission_classes=[IsTenantUser, HasMemberToken])
    def deduct_balance(self, request, **kwargs):
        """POST /{slug}/members/deduct-balance/ — deduct from member balance after order."""
        member = get_member_from_request(request)
        if not member:
            return Response({'detail': '未提供认证令牌或令牌无效'}, status=status.HTTP_401_UNAUTHORIZED)

        amount = request.data.get('amount', 0)
        try:
            amount = int(amount) if amount else 0
        except (ValueError, TypeError):
            return Response({'detail': '金额无效'}, status=status.HTTP_400_BAD_REQUEST)

        with transaction.atomic():
            member = Member.objects.select_for_update().get(pk=member.pk)
            if amount <= 0 or amount > member.balance:
                return Response({'detail': '余额不足'}, status=status.HTTP_400_BAD_REQUEST)
            member.balance -= amount
            member.total_spent += amount
            member.points += int(round(amount))  # ponytail: 1 point per yuan
            member.save(update_fields=['balance', 'total_spent', 'points'])

        return Response({
            'balance': str(member.balance),
            'points': member.points,
            'deducted': amount,
        })
