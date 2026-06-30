"""POS views."""
from common.permissions import TenantAccessPermission
from rest_framework import viewsets
from rest_framework.filters import OrderingFilter

from .models import Order
from .serializers import OrderCreateSerializer, OrderDetailSerializer, OrderListSerializer


class OrderViewSet(viewsets.ModelViewSet):
    permission_classes = [TenantAccessPermission]
    filter_backends = [OrderingFilter]
    ordering_fields = ['paid_at', 'total_amount']

    def get_queryset(self):
        return Order.objects.filter(tenant=self.request.tenant).prefetch_related('items')

    def get_serializer_class(self):
        if self.action == 'create':
            return OrderCreateSerializer
        if self.action in ('list',):
            return OrderListSerializer
        return OrderDetailSerializer

    def perform_create(self, serializer):
        serializer.save()
