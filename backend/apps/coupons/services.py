"""Coupon validation service — single entry point for all coupon rules.

Returns ValidateResult with `eligible_amount` so the caller can compute the
actual discount on the right basis (whole cart vs category-restricted subset).
"""
from dataclasses import dataclass
from decimal import Decimal

from django.utils import timezone

from .models import Coupon


@dataclass
class ValidateResult:
    valid: bool
    reason: str  # human-readable reason when invalid
    eligible_amount: Decimal = Decimal('0')  # cart subtotal the coupon applies to


class CouponService:
    """下单时校验优惠券是否可用。校验链短路返回："""

    def validate(self, coupon: Coupon, member, order) -> ValidateResult:
        """
        ① 券是否存在且启用
        ② 会员是否持有且未使用
        ③ 是否在有效期内
        ④ 是否首单券 + 会员是否符合首单条件
        ⑤ 计算适用金额（全场 or 品类限定）
        ⑥ 适用金额是否满门槛
        """
        # ① 启用
        if not coupon.is_active:
            return ValidateResult(False, '该优惠券已停用')

        # ② 持有 + 未使用
        from .models import MemberCoupon
        if not MemberCoupon.objects.filter(member=member, coupon=coupon, used=False).exists():
            return ValidateResult(False, '您未持有该优惠券或已使用')

        # ③ 有效期
        now = timezone.now()
        if coupon.valid_from and now < coupon.valid_from:
            return ValidateResult(False, '该优惠券尚未生效')
        if coupon.valid_until and now > coupon.valid_until:
            return ValidateResult(False, '该优惠券已过期')

        # ④ 首单限制：排除当前正在下的这笔订单
        if coupon.first_order_only:
            from apps.pos.models import Order
            prior_count = Order.objects.filter(
                member=member, tenant=member.tenant,
            ).exclude(pk=order.pk).count()
            if prior_count > 0:
                return ValidateResult(False, '该优惠券仅限首单使用')

        # ⑤ 计算适用金额（决定 min_amount 与折扣基数）
        cart_items = list(order.items.all())
        if coupon.is_universal:
            eligible = sum((item.subtotal for item in cart_items), Decimal('0'))
        else:
            allowed_ids = set(coupon.categories.values_list('id', flat=True))
            eligible = sum(
                (item.subtotal for item in cart_items if _item_category_id(item) in allowed_ids),
                Decimal('0'),
            )
            if eligible == 0:
                return ValidateResult(False, '购物车中没有该券适用的商品')

        # ⑥ 满门槛（按适用金额算，不是整单金额）
        if eligible < coupon.min_amount:
            return ValidateResult(
                False,
                f'适用商品金额 ¥{eligible:.2f} 未满 ¥{coupon.min_amount}',
            )

        return ValidateResult(True, 'ok', eligible)


def _item_category_id(item) -> int | None:
    """Extract category_id from an OrderItem via its SKU → Product FK."""
    sku = getattr(item, 'sku', None)
    if sku is None:
        return None
    product = getattr(sku, 'product', None)
    return getattr(product, 'category_id', None)


coupon_service = CouponService()
