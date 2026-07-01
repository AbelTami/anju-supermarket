"""POS views."""
from common.permissions import IsTenantUser
from rest_framework import viewsets
from rest_framework.filters import OrderingFilter
from rest_framework.permissions import AllowAny, IsAuthenticated

from .models import Order
from .serializers import OrderCreateSerializer, OrderDetailSerializer, OrderListSerializer


def _get_member_from_token(request):
    """Extract member from Authorization: Token header, or return None."""
    from apps.members.models import Member
    auth = request.headers.get('Authorization', '')
    if auth.startswith('Token '):
        token = auth[6:]
        try:
            return Member.objects.get(token=token, tenant=request.tenant)
        except Member.DoesNotExist:
            pass
    return None


class OrderViewSet(viewsets.ModelViewSet):
    filter_backends = [OrderingFilter]
    ordering_fields = ['paid_at', 'total_amount']

    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        if self.action == 'list':
            return [IsTenantUser()]
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

    def perform_create(self, serializer):
        from apps.accounts.models import User
        from rest_framework.exceptions import AuthenticationFailed
        fallback_user = User.objects.filter(is_superuser=True).first()

        # Validate member token if provided — reject invalid tokens
        auth = self.request.headers.get('Authorization', '')
        member = None
        if auth.startswith('Token '):
            member = _get_member_from_token(self.request)
            if not member:
                raise AuthenticationFailed('无效的会员令牌')

        serializer.save(cashier=fallback_user, tenant=self.request.tenant, member=member)
