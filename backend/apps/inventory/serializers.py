from rest_framework import serializers

from .models import InventoryRecord, StockCheck


class InventoryRecordSerializer(serializers.ModelSerializer):
    type_label = serializers.CharField(source='get_type_display', read_only=True)
    operator_name = serializers.CharField(source='operator.username', read_only=True)

    class Meta:
        model = InventoryRecord
        fields = ['id', 'type', 'type_label', 'quantity', 'before_quantity', 'after_quantity', 'remark', 'operator_name', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']


class StockCheckSerializer(serializers.ModelSerializer):
    status_label = serializers.CharField(source='get_status_display', read_only=True)

    class Meta:
        model = StockCheck
        fields = ['id', 'status', 'status_label', 'remark', 'created_by', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']
