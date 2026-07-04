"""POS收银 — 订单与支付."""
from common.models import TenantAwareModel
from django.db import models


class Order(TenantAwareModel):
    """收银订单."""

    class PaymentMethod(models.TextChoices):
        CASH = 'cash', '现金'
        WECHAT = 'wechat', '微信'
        ALIPAY = 'alipay', '支付宝'
        MEMBER_CARD = 'member_card', '会员卡'

    order_no = models.CharField(max_length=50, unique=True, verbose_name='订单号')
    total_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='总金额')
    discount_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='优惠金额')
    paid_amount = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='实收金额')
    payment_method = models.CharField(max_length=20, choices=PaymentMethod.choices, verbose_name='支付方式')
    member = models.ForeignKey('members.Member', on_delete=models.SET_NULL, null=True, blank=True, verbose_name='会员')
    cashier = models.ForeignKey('accounts.User', on_delete=models.PROTECT, null=True, blank=True, verbose_name='收银员')
    status = models.CharField(max_length=20, default='completed', verbose_name='状态')
    paid_at = models.DateTimeField(auto_now_add=True, verbose_name='支付时间')

    class Meta:
        db_table = 'pos_order'
        verbose_name = '收银订单'
        ordering = ['-paid_at']


class OrderItem(TenantAwareModel):
    """订单明细行."""

    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items', verbose_name='订单')
    sku = models.ForeignKey('products.ProductSKU', on_delete=models.PROTECT, verbose_name='商品SKU')
    product_name = models.CharField(max_length=200, verbose_name='商品名称')
    spec_name = models.CharField(max_length=200, default='', blank=True, verbose_name='规格')
    quantity = models.DecimalField(max_digits=10, decimal_places=3, verbose_name='数量')
    price = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='单价')
    subtotal = models.DecimalField(max_digits=10, decimal_places=2, verbose_name='小计')

    class Meta:
        db_table = 'pos_order_item'
        verbose_name = '订单明细'
