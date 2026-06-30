"""Employee views — users within a tenant."""
from common.permissions import TenantAccessPermission
from django.db.models import OuterRef, Subquery
from rest_framework import status, viewsets
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.response import Response

from apps.accounts.models import User, UserTenant
from .serializers import EmployeeAddSerializer, EmployeeSerializer


class EmployeeViewSet(viewsets.ModelViewSet):
    """List/create/delete tenant employees."""

    permission_classes = [TenantAccessPermission]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['username', 'first_name', 'phone']
    ordering_fields = ['username', 'date_joined']

    def get_queryset(self):
        tenant_roles = UserTenant.objects.filter(user=OuterRef('pk'), tenant=self.request.tenant)
        return User.objects.filter(tenants=self.request.tenant).annotate(
            _role=Subquery(tenant_roles.values('role')[:1])
        )

    def get_serializer_class(self):
        if self.action == 'create':
            return EmployeeAddSerializer
        return EmployeeSerializer

    def perform_create(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        UserTenant.objects.filter(user=instance, tenant=self.request.tenant).delete()
