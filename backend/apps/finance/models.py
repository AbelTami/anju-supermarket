"""财务 — 日结/月结对账."""
from common.models import TenantAwareModel
from django.db import models


class DailySummary(TenantAwareModel):
    """每日经营汇总."""

    date = models.DateField(verbose_name='日期')
    total_orders = models.IntegerField(default=0, verbose_name='订单数')
    total_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='营业额')
    cash_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='现金收款')
    wechat_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='微信收款')
    alipay_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='支付宝收款')
    member_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='会员卡收款')

    class Meta:
        db_table = 'finance_daily_summary'
        unique_together = [['tenant', 'date']]
        verbose_name = '日结汇总'
