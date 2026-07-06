"""Coupon serializers."""
from rest_framework import serializers

from .models import Coupon, MemberCoupon


class CouponSerializer(serializers.ModelSerializer):
    discount_type_label = serializers.CharField(source='get_discount_type_display', read_only=True)
    category_names = serializers.SerializerMethodField()
    scope_label = serializers.SerializerMethodField()

    class Meta:
        model = Coupon
        fields = ['id', 'title', 'discount_type', 'discount_type_label', 'discount_value',
                  'min_amount', 'total_count', 'used_count', 'valid_from', 'valid_until',
                  'is_active', 'categories', 'category_names', 'scope_label', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']

    def get_category_names(self, obj):
        return [c.name for c in obj.categories.all()]

    def get_scope_label(self, obj):
        return obj.scope_label


class MemberCouponSerializer(serializers.ModelSerializer):
    """Member's owned coupon — exposes everything the checkout page needs to
    pre-validate eligibility without another round-trip."""
    coupon_id = serializers.IntegerField(source='coupon.id', read_only=True)
    coupon_title = serializers.CharField(source='coupon.title', read_only=True)
    discount_type = serializers.CharField(source='coupon.discount_type', read_only=True)
    discount_value = serializers.CharField(source='coupon.discount_value', read_only=True)
    min_amount = serializers.CharField(source='coupon.min_amount', read_only=True)
    valid_until = serializers.DateTimeField(source='coupon.valid_until', read_only=True)
    scope_label = serializers.CharField(source='coupon.scope_label', read_only=True)
    category_ids = serializers.SerializerMethodField()
    first_order_only = serializers.BooleanField(source='coupon.first_order_only', read_only=True)

    class Meta:
        model = MemberCoupon
        fields = ['id', 'coupon_id', 'code', 'used', 'used_at', 'coupon_title', 'discount_type',
                  'discount_value', 'min_amount', 'valid_until', 'scope_label',
                  'category_ids', 'first_order_only', 'created_at']
        read_only_fields = ['id', 'created_at']

    def get_category_ids(self, obj):
        return [c.id for c in obj.coupon.categories.all()]
