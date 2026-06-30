"""DRF permissions for multi-tenant API."""
from rest_framework import permissions


class IsTenantUser(permissions.BasePermission):
    """Require request to have a resolved tenant."""

    def has_permission(self, request, view):
        return request.tenant is not None


class TenantAccessPermission(permissions.BasePermission):
    """Only allow access to resources within the user's current tenant."""

    def has_permission(self, request, view):
        if not request.tenant:
            return False
        # Super admin bypasses tenant checks
        if request.user.is_superuser:
            return True
        return request.user.tenants.filter(pk=request.tenant.pk).exists()

    def has_object_permission(self, request, view, obj):
        # Ensure object belongs to current tenant
        if hasattr(obj, 'tenant_id') and request.tenant:
            return obj.tenant_id == request.tenant.id
        return True
