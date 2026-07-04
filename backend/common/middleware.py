"""Multi-tenant middleware — extracts tenant_slug from URL path."""
import re

from django.db import connection
from django.http import Http404

from apps.tenants.models import Tenant

# Slug must start with a letter/number, be 3-49 chars long, and only contain
# lowercase letters, digits, hyphens, and underscores.
SLUG_PATTERN = re.compile(r'^[a-z0-9][a-z0-9_-]{2,48}$')


class TenantMiddleware:
    """Extract tenant from URL prefix: /api/{tenant_slug}/...

    Skips /auth/ paths entirely — they are public and tenant-agnostic.
    Sets PostgreSQL session variable for RLS enforcement.
    """

    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        request.tenant = None
        path = request.path

        # Public auth routes — skip tenant resolution
        if path.startswith('/auth/') or '/auth/' in path:
            return self.get_response(request)

        if path.startswith('/api/'):
            parts = path.split('/')
            # /api/{tenant_slug}/...
            if len(parts) >= 3 and parts[2]:
                slug = parts[2]

                if not SLUG_PATTERN.match(slug):
                    raise Http404("Invalid tenant identifier")

                try:
                    request.tenant = Tenant.objects.get(slug=slug, is_active=True)
                    # Set PostgreSQL session variable for RLS enforcement
                    with connection.cursor() as cursor:
                        cursor.execute(
                            "SET SESSION app.tenant_id = %s",
                            [str(request.tenant.id)],
                        )
                except Tenant.DoesNotExist:
                    raise Http404("Tenant not found")

        return self.get_response(request)
