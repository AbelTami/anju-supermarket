"""Coupon service tests — focused on the validation chain.

Run: python manage.py test apps.coupons
"""
from django.test import TestCase
from django.utils import timezone

from apps.coupons.models import Coupon, MemberCoupon
from apps.coupons.services import coupon_service
from apps.members.models import Member
from apps.tenants.models import Tenant


class CouponServiceTest(TestCase):
    def setUp(self):
        self.tenant = Tenant.objects.create(name='Test Store', slug='test1')
        self.member = Member.objects.create(
            tenant=self.tenant, name='Zhang', phone='13800000001'
        )
        self.coupon = Coupon.objects.create(
            tenant=self.tenant, title='满100减10',
            discount_type=Coupon.DiscountType.FIXED,
            discount_value=10, min_amount=100, is_active=True,
        )
        MemberCoupon.objects.create(
            tenant=self.tenant, member=self.member, coupon=self.coupon,
            code='C1', used=False,
        )

    def test_universal_coupon_skips_category_check(self):
        """A coupon with no category restriction applies to any cart."""
        # Build a fake cart item — duck-typed, no DB needed.
        class FakeItem:
            subtotal = 200
            class _Sku:
                class _Product:
                    name = 'P'
                    category_id = 999  # not in coupon.categories
                product = _Product()
            sku = _Sku()
        result = coupon_service.validate(self.coupon, self.member, [FakeItem()])
        self.assertTrue(result.valid, result.reason)

    def test_inactive_coupon_rejected(self):
        self.coupon.is_active = False
        self.coupon.save()
        result = coupon_service.validate(self.coupon, self.member, [])
        self.assertFalse(result.valid)
        self.assertIn('停用', result.reason)

    def test_member_without_coupon_rejected(self):
        """Coupon not in member's wallet → reject."""
        other = Coupon.objects.create(
            tenant=self.tenant, title='Other',
            discount_type=Coupon.DiscountType.FIXED,
            discount_value=5, min_amount=0, is_active=True,
        )
        result = coupon_service.validate(other, self.member, [])
        self.assertFalse(result.valid)

    def test_below_minimum_amount_rejected(self):
        class FakeItem:
            subtotal = 50  # below 100 min_amount
        result = coupon_service.validate(self.coupon, self.member, [FakeItem()])
        self.assertFalse(result.valid)
        self.assertIn('未满', result.reason)
