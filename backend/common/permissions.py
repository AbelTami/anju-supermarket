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


# ponytail: role-based permissions — simple inheritance, reusable base class.
class RolePermission(permissions.BasePermission):
    """Base class for role-based permissions. Subclasses define ALLOWED_ROLES."""

    # Subclasses override this
    ALLOWED_ROLES: set[str] = set()

    def _get_user_role(self, request) -> str | None:
        """Get user's role in current tenant."""
        if not request.user.is_authenticated or not request.tenant:
            return None
        return (
            UserTenant.objects
            .filter(user=request.user, tenant=request.tenant)
            .values_list('role', flat=True)
            .first()
        )

    def has_permission(self, request, view):
        role = self._get_user_role(request)
        return role in self.ALLOWED_ROLES


class IsSuperAdmin(RolePermission):
    """Only super_admin can access."""
    ALLOWED_ROLES = {'super_admin'}


class IsAdminOrManager(RolePermission):
    """super_admin or manager can access."""
    ALLOWED_ROLES = {'super_admin', 'manager'}


class IsCashier(RolePermission):
    """cashier (and above) can access."""
    ALLOWED_ROLES = {'cashier', 'manager', 'super_admin'}


class IsWarehouse(RolePermission):
    """warehouse staff (and above) can access."""
    ALLOWED_ROLES = {'warehouse', 'manager', 'super_admin'}


class IsAccountant(RolePermission):
    """accountant (and above) can access."""
    ALLOWED_ROLES = {'accountant', 'manager', 'super_admin'}


class IsAccountantOrManager(RolePermission):
    """accountant or manager can access."""
    ALLOWED_ROLES = {'accountant', 'manager', 'super_admin'}


class IsWarehouseOrAdmin(RolePermission):
    """warehouse staff, manager, or super_admin can access."""
    ALLOWED_ROLES = {'warehouse', 'manager', 'super_admin'}


class IsAuthenticatedCashierOrMember(permissions.BasePermission):
    """Allow access if authenticated as cashier/staff OR has valid member token."""

    def has_permission(self, request, view):
        # Check for member token first
        auth = request.headers.get('Authorization', '')
        if auth.startswith('Token '):
            return get_member_from_request(request) is not None

        # Check for authenticated cashier/staff
        if not request.user.is_authenticated or not request.tenant:
            return False
        role = (
            UserTenant.objects
            .filter(user=request.user, tenant=request.tenant)
            .values_list('role', flat=True)
            .first()
        )
        return role in {'cashier', 'manager', 'super_admin'}


# Legacy alias — kept for backward compatibility
class IsSuperAdminOrManager(IsAdminOrManager):
    """Deprecated: use IsAdminOrManager instead."""
    pass
