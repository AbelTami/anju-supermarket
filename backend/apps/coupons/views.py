"""Coupon views — admin CRUD + member self-list."""
import uuid

from common.permissions import HasMemberToken, IsTenantUser
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Coupon, MemberCoupon
from .serializers import CouponSerializer, MemberCouponSerializer


class CouponViewSet(viewsets.ModelViewSet):
    """Admin CRUD for coupon templates."""
    permission_classes = [IsAuthenticated, IsTenantUser]
    serializer_class = CouponSerializer

    def get_queryset(self):
        return Coupon.objects.filter(tenant=self.request.tenant).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)

    @action(detail=True, methods=['post'], url_path='assign')
    def assign_to_members(self, request, **kwargs):
        """POST /{slug}/coupons/{id}/assign/ — batch assign to members."""
        coupon = self.get_object()
        member_ids = request.data.get('member_ids', [])
        if not member_ids:
            return Response({'detail': '请提供会员ID列表'}, status=status.HTTP_400_BAD_REQUEST)

        count = 0
        for mid in member_ids:
            if MemberCoupon.objects.filter(coupon=coupon, member_id=mid).exists():
                continue
            MemberCoupon.objects.create(
                tenant=coupon.tenant,
                coupon=coupon,
                member_id=mid,
                code=f'COUPON-{uuid.uuid4().hex[:8].upper()}',
            )
            count += 1

        coupon.used_count = MemberCoupon.objects.filter(coupon=coupon).count()
        coupon.save(update_fields=['used_count'])

        return Response({'assigned': count})


class MemberCouponViewSet(viewsets.ReadOnlyModelViewSet):
    """Member self-view for owned coupons."""
    permission_classes = [IsTenantUser, HasMemberToken]
    serializer_class = MemberCouponSerializer

    def get_queryset(self):
        from common.token_utils import get_member_from_request
        member = get_member_from_request(self.request)
        if not member:
            return MemberCoupon.objects.none()
        return MemberCoupon.objects.filter(
            tenant=self.request.tenant,
            member=member,
        ).select_related('coupon').order_by('-created_at')
