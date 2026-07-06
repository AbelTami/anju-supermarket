"""POS serializers.

Amount fields (total/discount/paid) are NEVER taken from the client. The server
recomputes from ProductSKU.selling_price × quantity, then applies coupon
discount in the view. This closes the price-tampering vector (C1).

Stock is deducted inside the same transaction that creates the order, with
SELECT ... FOR UPDATE on the SKU rows — closes the oversell vector (C2).
"""
import uuid
from decimal import Decimal

from rest_framework import serializers

from apps.products.models import ProductSKU
from .models import Order, OrderItem


class OrderItemSerializer(serializers.ModelSerializer):
    """Read-only view of an order line.

    For writes, only `sku` and `quantity` are honoured — `price` and `subtotal`
    are recomputed server-side from the SKU's current selling price.
    """
    class Meta:
        model = OrderItem
        fields = ['id', 'sku', 'product_name', 'spec_name', 'quantity', 'price', 'subtotal']
        read_only_fields = ['product_name', 'spec_name', 'price', 'subtotal']


class OrderCreateSerializer(serializers.ModelSerializer):
    """Create order with nested items. Amounts are server-authoritative."""
    items = OrderItemSerializer(many=True)
    coupon_id = serializers.IntegerField(required=False, allow_null=True, write_only=True)

    class Meta:
        model = Order
        # total_amount / discount_amount / paid_amount deliberately omitted —
        # the server computes them. The client only chooses payment method,
        # optional member, items, and an optional coupon.
        fields = ['payment_method', 'member', 'items', 'coupon_id']

    def validate_items(self, items):
        if not items:
            raise serializers.ValidationError('订单至少需要一个商品')
        return items

    def create(self, validated_data):
        items_data = validated_data.pop('items')
        coupon_id = validated_data.pop('coupon_id', None)
        request = self.context['request']
        tenant = request.tenant

        # ponytail: lock exactly the SKUs this order touches — concurrent orders
        # on different SKUs don't block each other.
        sku_ids = [item['sku'].id for item in items_data]
        skus = {
            s.id: s
            for s in ProductSKU.objects.select_for_update().filter(
                tenant=tenant, id__in=sku_ids
            )
        }
        if len(skus) != len(sku_ids):
            raise serializers.ValidationError({'items': '包含无效的 SKU'})

        # Pre-compute totals and prepare item rows BEFORE creating the Order —
        # post_save fires once with the final amounts, so SSE pushes the right
        # numbers. (Previously: created with 0, updated later, signal fired
        # twice and the first — wrong — event was the one published.)
        total = Decimal('0')
        pending: list[tuple[ProductSKU, Decimal, Decimal]] = []
        for item_data in items_data:
            sku = skus[item_data['sku'].id]
            qty = Decimal(item_data['quantity'])
            if qty <= 0:
                raise serializers.ValidationError({'items': '数量必须大于 0'})
            if sku.stock_quantity < qty:
                raise serializers.ValidationError(
                    {'items': f'「{sku.product.name} - {sku.spec_name}」库存不足'}
                )
            subtotal = (sku.selling_price * qty).quantize(Decimal('0.01'))
            total += subtotal
            pending.append((sku, qty, subtotal))

        order = Order.objects.create(
            tenant=tenant,
            order_no=f'POS{uuid.uuid4().hex[:12].upper()}',
            payment_method=validated_data['payment_method'],
            member=validated_data.get('member'),
            cashier=request.user if request.user.is_authenticated else None,
            total_amount=total,
            discount_amount=Decimal('0'),
            paid_amount=total,
        )

        # Order now has a PK — create the items and deduct stock.
        for sku, qty, subtotal in pending:
            OrderItem.objects.create(
                tenant=tenant, order=order, sku=sku,
                product_name=sku.product.name, spec_name=sku.spec_name,
                quantity=qty, price=sku.selling_price, subtotal=subtotal,
            )
            sku.stock_quantity -= qty
            sku.save(update_fields=['stock_quantity'])

        # Stash for the view — it needs to validate coupon ownership & member.
        order._coupon_id = coupon_id
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
    member_name = serializers.SerializerMethodField()
    member_phone = serializers.SerializerMethodField()
    member_card_no = serializers.SerializerMethodField()
    member_points_earned = serializers.SerializerMethodField()

    class Meta:
        model = Order
        fields = [
            'id', 'order_no', 'total_amount', 'discount_amount', 'paid_amount',
            'payment_method', 'member', 'cashier_name', 'items', 'paid_at',
            'member_name', 'member_phone', 'member_card_no', 'member_points_earned',
        ]

    def get_cashier_name(self, obj):
        return obj.cashier.username if obj.cashier else ''

    def get_member_name(self, obj):
        return obj.member.name if obj.member else ''

    def get_member_phone(self, obj):
        if not obj.member:
            return ''
        phone = obj.member.phone or ''
        if len(phone) >= 7:
            return phone[:3] + '****' + phone[-4:]
        return phone

    def get_member_card_no(self, obj):
        return obj.member.card_no if obj.member else ''

    def get_member_points_earned(self, obj):
        # 1 point per yuan, same logic as perform_create
        return int(round(obj.paid_amount)) if obj.paid_amount else 0
