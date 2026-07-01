"""会员管理."""
from common.models import TenantAwareModel
from django.db import models


class Member(TenantAwareModel):
    """会员."""

    name = models.CharField(max_length=100, verbose_name='姓名')
    phone = models.CharField(max_length=20, verbose_name='手机号')
    password = models.CharField(max_length=128, default='', verbose_name='密码')
    token = models.CharField(max_length=128, blank=True, default='', verbose_name='登录令牌')
    card_no = models.CharField(max_length=50, blank=True, default='', verbose_name='会员卡号')
    points = models.IntegerField(default=0, verbose_name='积分')
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='储值余额')
    total_spent = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='累计消费')
    remark = models.TextField(blank=True, default='', verbose_name='备注')

    class Meta:
        db_table = 'member'
        verbose_name = '会员'
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.name} ({self.phone})'
