from common.permissions import IsTenantUser
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Tenant
from .serializers import TenantPublicSerializer, TenantSerializer


class TenantDetailView(APIView):
    """GET/PATCH /api/{slug}/ — current tenant info (admin only)."""

    permission_classes = [IsAuthenticated, IsTenantUser]

    def get(self, request, **kwargs):
        return Response(TenantSerializer(request.tenant).data)

    def patch(self, request, **kwargs):
        serializer = TenantSerializer(request.tenant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class TenantPublicView(APIView):
    """GET /api/{slug}/info/ — public storefront info (name, hours, broadcast).

    No auth: the customer-facing storefront needs this to render the broadcast
    banner and store header. Internal flags (is_active) stay admin-only.
    """
    permission_classes: list = []

    def get(self, request, tenant_slug, **kwargs):
        try:
            tenant = Tenant.objects.get(slug=tenant_slug, is_active=True)
        except Tenant.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)
        return Response(TenantPublicSerializer(tenant).data)
