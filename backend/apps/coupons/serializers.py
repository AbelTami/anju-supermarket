"""Coupon serializers."""
from rest_framework import serializers

from .models import Coupon, MemberCoupon


class CouponSerializer(serializers.ModelSerializer):
    discount_type_label = serializers.CharField(source='get_discount_type_display', read_only=True)

    class Meta:
        model = Coupon
        fields = ['id', 'title', 'discount_type', 'discount_type_label', 'discount_value',
                  'min_amount', 'total_count', 'used_count', 'valid_from', 'valid_until',
                  'is_active', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']


class MemberCouponSerializer(serializers.ModelSerializer):
    coupon_title = serializers.CharField(source='coupon.title', read_only=True)
    discount_type = serializers.CharField(source='coupon.discount_type', read_only=True)
    discount_value = serializers.CharField(source='coupon.discount_value', read_only=True)
    min_amount = serializers.CharField(source='coupon.min_amount', read_only=True)
    valid_until = serializers.DateTimeField(source='coupon.valid_until', read_only=True)

    class Meta:
        model = MemberCoupon
        fields = ['id', 'code', 'used', 'used_at', 'coupon_title', 'discount_type',
                  'discount_value', 'min_amount', 'valid_until', 'created_at']
        read_only_fields = ['id', 'created_at']
