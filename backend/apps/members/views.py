"""Member views — full CRUD."""
from common.permissions import TenantAccessPermission
from rest_framework import viewsets
from rest_framework.filters import OrderingFilter, SearchFilter

from .models import Member
from .serializers import MemberSerializer


class MemberViewSet(viewsets.ModelViewSet):
    permission_classes = [TenantAccessPermission]
    serializer_class = MemberSerializer
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['name', 'phone', 'card_no']
    ordering_fields = ['name', 'points', 'total_spent', 'created_at']

    def get_queryset(self):
        return Member.objects.filter(tenant=self.request.tenant)

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)
