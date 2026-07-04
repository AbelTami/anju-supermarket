"""DRF permissions for multi-tenant API."""
from rest_framework import permissions

from apps.accounts.models import UserTenant
from common.token_utils import get_member_from_request


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


class HasMemberToken(permissions.BasePermission):
    """Allow access if the request carries a valid Member token in the Authorization header.

    Checks for 'Token <hex>' and verifies the token belongs to a member
    in the current tenant.
    """

    def has_permission(self, request, view):
        if not request.tenant:
            return False
        return get_member_from_request(request) is not None


class IsSuperAdminOrManager(permissions.BasePermission):
    """Allow access only for users with super_admin or manager role in the current tenant."""

    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        if not request.tenant:
            return False
        role = (
            UserTenant.objects
            .filter(user=request.user, tenant=request.tenant)
            .values_list('role', flat=True)
            .first()
        )
        return role in ('super_admin', 'manager')
