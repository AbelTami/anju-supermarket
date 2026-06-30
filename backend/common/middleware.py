"""Multi-tenant middleware — extracts tenant_slug from URL path."""
from django.http import Http404

from apps.tenants.models import Tenant


class TenantMiddleware:
    """Extract tenant from URL prefix: /api/{tenant_slug}/..."""

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Assign default — public routes (auth) won't set it
        request.tenant = None
        path = request.path

        if path.startswith('/api/'):
            parts = path.split('/')
            # /api/{tenant_slug}/...
            if len(parts) >= 3 and parts[2]:
                slug = parts[2]
                # Heuristic: if slug matches a known tenant, set it
                try:
                    request.tenant = Tenant.objects.get(slug=slug, is_active=True)
                except Tenant.DoesNotExist:
                    # Not a tenant route; let it pass (public routes like auth)
                    pass

        return self.get_response(request)
