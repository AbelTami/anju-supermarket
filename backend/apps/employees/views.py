"""Employee views — users within a tenant."""
from common.permissions import IsSuperAdminOrManager, IsTenantUser
from django.db.models import OuterRef, Subquery
from rest_framework import status, viewsets
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.accounts.models import User, UserTenant
from .serializers import EmployeeAddSerializer, EmployeeSerializer, EmployeeUpdateSerializer


class EmployeeViewSet(viewsets.ModelViewSet):
    """List/create/delete tenant employees."""

    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['username', 'first_name', 'phone']
    ordering_fields = ['username', 'date_joined']

    def get_permissions(self):
        if self.action in ('create', 'update', 'partial_update', 'destroy'):
            return [IsAuthenticated(), IsTenantUser(), IsSuperAdminOrManager()]
        return [IsAuthenticated(), IsTenantUser()]

    def get_queryset(self):
        tenant_roles = UserTenant.objects.filter(user=OuterRef('pk'), tenant=self.request.tenant)
        return User.objects.filter(tenants=self.request.tenant).annotate(
            _role=Subquery(tenant_roles.values('role')[:1])
        )

    def get_serializer_class(self):
        if self.action == 'create':
            return EmployeeAddSerializer
        if self.action in ('update', 'partial_update'):
            return EmployeeUpdateSerializer
        return EmployeeSerializer

    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        # Re-fetch with annotation so _role reflects the change
        instance = self.get_queryset().get(pk=instance.pk)
        read_serializer = EmployeeSerializer(instance, context={'request': request})
        return Response(read_serializer.data)

    def perform_destroy(self, instance):
        UserTenant.objects.filter(user=instance, tenant=self.request.tenant).delete()
