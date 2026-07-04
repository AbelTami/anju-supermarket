"""Inventory views — stock mutation, stock check, low-stock alert."""
from common.permissions import IsTenantUser
from django.db import transaction
from rest_framework import serializers, status, viewsets
from rest_framework.decorators import action
from rest_framework.filters import OrderingFilter, SearchFilter
from django.db.models import F
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.products.models import ProductSKU
from .models import InventoryRecord, StockCheck, StockCheckItem
from .serializers import (
    InventoryRecordSerializer,
    StockCheckItemSerializer,
    StockCheckSerializer,
    StockCheckWriteSerializer,
)


class InventoryRecordWriteSerializer(serializers.ModelSerializer):
    class Meta:
        model = InventoryRecord
        fields = ['sku', 'type', 'quantity', 'remark']


class InventoryRecordViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsTenantUser]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['sku__product__name', 'sku__barcode']
    ordering_fields = ['created_at', 'quantity']
    filterset_fields = ['type']

    def get_queryset(self):
        return InventoryRecord.objects.filter(
            tenant=self.request.tenant,
        ).select_related('sku__product', 'operator').order_by('-created_at')

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

        sku = ProductSKU.objects.select_for_update().get(pk=sku_id, tenant=tenant)
        before = sku.stock_quantity

        if rtype in ('purchase_in', 'return_in', 'check_in'):
            after = before + qty
        else:
            after = before - qty

        sku.stock_quantity = after
        sku.save(update_fields=['stock_quantity'])

        serializer.save(tenant=tenant, operator=self.request.user, before_quantity=before, after_quantity=after)

    @action(detail=False, methods=['get'], url_path='low-stock')
    def low_stock(self, request, **kwargs):
        """GET /api/{slug}/inventory-records/low-stock/ — SKUs below stock_alert."""
        tenant = request.tenant
        low_skus = ProductSKU.objects.filter(
            tenant=tenant,
            stock_alert__gt=0,
            stock_quantity__lte=F('stock_alert'),
        ).select_related('product').order_by('stock_quantity')

        return Response({
            'count': low_skus.count(),
            'results': [
                {
                    'sku_id': s.id,
                    'product_name': s.product.name,
                    'spec_name': s.spec_name,
                    'barcode': s.barcode,
                    'stock_quantity': str(s.stock_quantity),
                    'stock_alert': str(s.stock_alert),
                }
                for s in low_skus
            ],
        })

class StockCheckViewSet(viewsets.ModelViewSet):
    permission_classes = [IsAuthenticated, IsTenantUser]
    ordering_fields = ['created_at', 'status']

    def get_queryset(self):
        return StockCheck.objects.filter(
            tenant=self.request.tenant,
        ).prefetch_related('items__sku__product')

    def get_serializer_class(self):
        if self.action == 'create':
            return StockCheckWriteSerializer
        return StockCheckSerializer

    def create(self, request, *args, **kwargs):
        """Create stock check, then return with full serializer (includes id/status)."""
        write_serializer = self.get_serializer(data=request.data)
        write_serializer.is_valid(raise_exception=True)
        self.perform_create(write_serializer)
        read_serializer = StockCheckSerializer(write_serializer.instance)
        return Response(read_serializer.data, status=status.HTTP_201_CREATED)

    @action(detail=True, methods=['post'], url_path='complete')
    def complete(self, request, **kwargs):
        """POST /api/{slug}/stock-checks/{id}/complete/ — finish stock check, auto-generate inventory records."""
        tenant = request.tenant
        records_created = 0

        with transaction.atomic():
            stock_check = StockCheck.objects.select_for_update().get(pk=kwargs['pk'], tenant=request.tenant)
            if stock_check.status != 'checking':
                return Response({'error': '只有盘点中的单据可以完成'}, status=status.HTTP_400_BAD_REQUEST)

            for item in stock_check.items.select_related('sku').all():
                diff = item.actual_quantity - item.system_quantity
                if diff == 0:
                    item.diff_quantity = 0
                    item.save(update_fields=['diff_quantity'])
                    continue

                item.diff_quantity = diff
                item.save(update_fields=['diff_quantity'])

                rtype = 'check_in' if diff > 0 else 'check_out'
                abs_qty = abs(diff)

                sku = ProductSKU.objects.select_for_update().get(pk=item.sku_id, tenant=tenant)
                before = sku.stock_quantity
                after = before + diff
                sku.stock_quantity = after
                sku.save(update_fields=['stock_quantity'])

                InventoryRecord.objects.create(
                    tenant=tenant,
                    sku=sku,
                    type=rtype,
                    quantity=abs_qty,
                    before_quantity=before,
                    after_quantity=after,
                    operator=request.user,
                    remark=f'盘点单 #{stock_check.id} 自动生成',
                )
                records_created += 1

            stock_check.status = 'done'
            stock_check.save(update_fields=['status'])

        return Response({'status': 'done', 'records_created': records_created})
