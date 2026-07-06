from rest_framework import serializers

from .models import InventoryRecord, StockCheck, StockCheckItem


class SKUInfoMixin(serializers.Serializer):
    """Mixin providing read-only SKU info fields for serializers that reference a SKU."""
    sku_name = serializers.CharField(source='sku.product.name', read_only=True)
    sku_spec = serializers.CharField(source='sku.spec_name', read_only=True)
    sku_barcode = serializers.CharField(source='sku.barcode', read_only=True)


class InventoryRecordSerializer(serializers.ModelSerializer):
    type_label = serializers.CharField(source='get_type_display', read_only=True)
    operator_name = serializers.CharField(source='operator.username', read_only=True)
    sku_name = serializers.CharField(source='sku.product.name', read_only=True)
    sku_spec = serializers.CharField(source='sku.spec_name', read_only=True)
    sku_barcode = serializers.CharField(source='sku.barcode', read_only=True)

    class Meta:
        model = InventoryRecord
        fields = [
            'id', 'type', 'type_label', 'quantity', 'before_quantity', 'after_quantity',
            'remark', 'operator_name', 'sku_name', 'sku_spec', 'sku_barcode', 'created_at',
        ]
        read_only_fields = ['id', 'created_at', 'tenant']


class StockCheckItemSerializer(SKUInfoMixin, serializers.ModelSerializer):
    class Meta:
        model = StockCheckItem
        fields = ['id', 'sku', 'sku_name', 'sku_spec', 'sku_barcode',
                  'system_quantity', 'actual_quantity', 'diff_quantity', 'remark']
        read_only_fields = ['id', 'system_quantity']


class StockCheckSerializer(serializers.ModelSerializer):
    status_label = serializers.CharField(source='get_status_display', read_only=True)
    items = StockCheckItemSerializer(many=True, read_only=True)

    class Meta:
        model = StockCheck
        fields = ['id', 'status', 'status_label', 'remark', 'created_by', 'items', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']


class StockCheckWriteSerializer(serializers.ModelSerializer):
    """Create stock check with items in one request."""
    items = StockCheckItemSerializer(many=True)

    class Meta:
        model = StockCheck
        fields = ['remark', 'items']

    def create(self, validated_data):
        items_data = validated_data.pop('items', [])
        validated_data['tenant'] = self.context['request'].tenant
        validated_data['created_by'] = self.context['request'].user
        stock_check = StockCheck.objects.create(status='checking', **validated_data)
        for item in items_data:
            sku = item['sku']
            request = self.context.get('request')
            if request is not None and getattr(request, 'tenant', None) is not None:
                if sku.tenant_id != request.tenant.id:
                    raise serializers.ValidationError({'items': f'SKU {sku.barcode} 不属于当前超市'})
            StockCheckItem.objects.create(
                stock_check=stock_check,
                tenant=stock_check.tenant,
                system_quantity=sku.stock_quantity,
                **item,
            )
        return stock_check
