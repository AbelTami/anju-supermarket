"""Inventory views — stock mutation on record creation."""
from common.permissions import TenantAccessPermission
from django.db import transaction
from rest_framework import serializers, status, viewsets
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.response import Response

from apps.products.models import ProductSKU
from .models import InventoryRecord, StockCheck
from .serializers import InventoryRecordSerializer, StockCheckSerializer


class InventoryRecordWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryRecord
        fields = ['sku', 'type', 'quantity', 'remark']


class InventoryRecordViewSet(viewsets.ModelViewSet):
    permission_classes = [TenantAccessPermission]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['sku__product__name', 'sku__barcode']
    ordering_fields = ['created_at', 'quantity']
    filterset_fields = ['type']

    def get_queryset(self):
        return InventoryRecord.objects.filter(tenant=self.request.tenant).select_related('sku__product', 'operator')

    def get_serializer_class(self):
        if self.action == 'create':
            return InventoryRecordWriteSerializer
        return InventoryRecordSerializer

    @transaction.atomic
    def perform_create(self, serializer):
        tenant = self.request.tenant
        sku_id = serializer.validated_data['sku'].id
        qty = serializer.validated_data['quantity']
        rtype = serializer.validated_data['type']

        # Lock SKU row for atomic stock update
        sku = ProductSKU.objects.select_for_update().get(pk=sku_id, tenant=tenant)
        before = sku.stock_quantity

        # Stock-in types increase quantity, stock-out types decrease
        if rtype in ('purchase_in', 'return_in', 'check_in'):
            after = before + qty
        else:
            after = before - qty

        sku.stock_quantity = after
        sku.save(update_fields=['stock_quantity'])

        serializer.save(tenant=tenant, operator=self.request.user, before_quantity=before, after_quantity=after)


class StockCheckViewSet(viewsets.ModelViewSet):
    permission_classes = [TenantAccessPermission]
    serializer_class = StockCheckSerializer
    ordering_fields = ['created_at', 'status']

    def get_queryset(self):
        return StockCheck.objects.filter(tenant=self.request.tenant)

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant, created_by=self.request.user)
