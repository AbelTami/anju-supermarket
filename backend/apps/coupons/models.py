"""Coupon models — template coupons and member assignments."""
from common.models import TenantAwareModel
from django.db import models


class Coupon(TenantAwareModel):
    """优惠券模板."""

    class DiscountType(models.TextChoices):
        FIXED = 'fixed', '满减'
        PERCENT = 'percent', '折扣'

    title = models.CharField(max_length=100, verbose_name='名称')
    discount_type = models.CharField(max_length=10, choices=DiscountType.choices, default=DiscountType.FIXED, verbose_name='类型')
    discount_value = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='优惠值')
    min_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='最低消费')
    total_count = models.IntegerField(default=100, verbose_name='发行数')
    used_count = models.IntegerField(default=0, verbose_name='已领取')
    valid_from = models.DateTimeField(null=True, blank=True, verbose_name='生效')
    valid_until = models.DateTimeField(null=True, blank=True, verbose_name='过期')
    is_active = models.BooleanField(default=True, verbose_name='启用')
    first_order_only = models.BooleanField(default=False, verbose_name='仅限首单', help_text='勾选后只有无任何订单历史的会员能用')
    categories = models.ManyToManyField('products.Category', blank=True, verbose_name='适用品类', help_text='不选则全场通用')

    class Meta:
        db_table = 'coupon'
        verbose_name = '优惠券'

    @property
    def is_universal(self) -> bool:
        """品类为空 → 全场通用"""
        return not self.categories.exists()

    @property
    def scope_label(self) -> str:
        """前端可直接渲染的适用范围文字"""
        if self.is_universal:
            return '全场通用'
        names = '、'.join(c.name for c in self.categories.all())
        return f'仅限{names}'


class MemberCoupon(TenantAwareModel):
    """会员持有的优惠券."""

    member = models.ForeignKey('members.Member', on_delete=models.CASCADE, related_name='coupons', verbose_name='会员')
    coupon = models.ForeignKey(Coupon, on_delete=models.CASCADE, verbose_name='优惠券')
    code = models.CharField(max_length=50, unique=True, verbose_name='券码')
    used = models.BooleanField(default=False, verbose_name='已使用')
    used_at = models.DateTimeField(null=True, blank=True, verbose_name='使用时间')

    class Meta:
        db_table = 'member_coupon'
        verbose_name = '会员优惠券'
        unique_together = [['member', 'coupon']]
