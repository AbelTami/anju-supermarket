import time
import random

from rest_framework import serializers

from .models import Order, OrderItem


class OrderItemSerializer(serializers.ModelSerializer):
    class Meta:
        model = OrderItem
        fields = ['id', 'sku', 'product_name', 'spec_name', 'quantity', 'price', 'subtotal']


class OrderCreateSerializer(serializers.ModelSerializer):
    """Create order with nested items."""
    items = OrderItemSerializer(many=True)

    coupon_id = serializers.IntegerField(required=False, allow_null=True, write_only=True)

    class Meta:
        model = Order
        fields = ['total_amount', 'discount_amount', 'paid_amount', 'payment_method', 'member', 'items', 'coupon_id']

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        validated_data.pop('coupon_id', None)  # handled in perform_create, not on Order model
        validated_data['tenant'] = self.context['request'].tenant
        # Use passed cashier or fall back to request user
        if 'cashier' not in validated_data:
            validated_data['cashier'] = self.context['request'].user
        validated_data['order_no'] = f'POS{int(time.time())}{random.randint(100, 999)}'
        order = Order.objects.create(**validated_data)
        for item in items_data:
            item['tenant'] = order.tenant
            OrderItem.objects.create(order=order, **item)
        return order


class OrderListSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    items_count = serializers.IntegerField(source='items.count', read_only=True)
    cashier_name = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ['id', 'order_no', 'total_amount', 'discount_amount', 'paid_amount', 'payment_method', 'status', 'items', 'items_count', 'cashier_name', 'paid_at']

    def get_cashier_name(self, obj):
        return obj.cashier.username if obj.cashier else ''


class OrderDetailSerializer(serializers.ModelSerializer):
    items = OrderItemSerializer(many=True, read_only=True)
    cashier_name = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = ['id', 'order_no', 'total_amount', 'discount_amount', 'paid_amount', 'payment_method', 'member', 'cashier_name', 'items', 'paid_at']

    def get_cashier_name(self, obj):
        return obj.cashier.username if obj.cashier else ''
