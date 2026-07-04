"""Coupon validation service — single entry point for all coupon rules."""
from dataclasses import dataclass
from django.utils import timezone

from .models import Coupon


@dataclass
class ValidateResult:
    valid: bool
    reason: str  # human-readable reason when invalid


class CouponService:
    """下单时校验优惠券是否可用。校验链短路返回："""

    def validate(self, coupon: Coupon, member, cart_items: list) -> ValidateResult:
        """
        ① 券是否存在且启用
        ② 会员是否持有该券
        ③ 是否在有效期内
        ④ 是否已使用
        ⑤ 订单金额是否满门槛
        ⑥ 品类是否匹配
        """
        # ① 启用
        if not coupon.is_active:
            return ValidateResult(False, '该优惠券已停用')

        # ② 持有
        from .models import MemberCoupon
        if not MemberCoupon.objects.filter(member=member, coupon=coupon, used=False).exists():
            return ValidateResult(False, '您未持有该优惠券或已使用')

        # ③ 有效期
        now = timezone.now()
        if coupon.valid_from and now < coupon.valid_from:
            return ValidateResult(False, '该优惠券尚未生效')
        if coupon.valid_until and now > coupon.valid_until:
            return ValidateResult(False, '该优惠券已过期')

        # ⑤ 满门槛
        total = sum(getattr(item, 'subtotal', 0) or (getattr(item, 'price', 0) * getattr(item, 'quantity', 0)) for item in cart_items)
        if total < coupon.min_amount:
            return ValidateResult(False, f'订单金额 ¥{total:.2f} 未满 ¥{coupon.min_amount}，无法使用')

        # ⑥ 品类匹配
        if not coupon.is_universal:
            allowed_ids = set(coupon.categories.values_list('id', flat=True))
            for item in cart_items:
                # OrderItem has sku → product → category
                sku = getattr(item, 'sku', None)
                product = getattr(sku, 'product', None) if sku else getattr(item, 'product', None)
                if not product:
                    continue
                cat_id = getattr(product, 'category_id', None)
                if cat_id and cat_id not in allowed_ids:
                    return ValidateResult(False, f'「{product.name}」不在该券适用品类范围内')

        return ValidateResult(True, 'ok')


coupon_service = CouponService()
