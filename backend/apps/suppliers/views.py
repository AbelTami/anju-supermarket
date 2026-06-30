from common.permissions import TenantAccessPermission
from rest_framework import viewsets
from rest_framework.filters import OrderingFilter, SearchFilter

from .models import Supplier
from .serializers import SupplierSerializer


class SupplierViewSet(viewsets.ModelViewSet):
    permission_classes = [TenantAccessPermission]
    serializer_class = SupplierSerializer
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['name', 'contact', 'phone']
    ordering_fields = ['name', 'created_at']

    def get_queryset(self):
        return Supplier.objects.filter(tenant=self.request.tenant)

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)
