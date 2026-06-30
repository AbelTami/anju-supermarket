from common.permissions import TenantAccessPermission
from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import Tenant
from .serializers import TenantSerializer


class TenantDetailView(APIView):
    """GET/PATCH /api/{slug}/ — current tenant info."""
    permission_classes = [TenantAccessPermission]

    def get(self, request, **kwargs):
        return Response(TenantSerializer(request.tenant).data)

    def patch(self, request, **kwargs):
        serializer = TenantSerializer(request.tenant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
