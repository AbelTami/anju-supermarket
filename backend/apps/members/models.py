"""会员管理."""
from datetime import timedelta

from common.models import TenantAwareModel
from django.db import models
from django.utils import timezone


class Member(TenantAwareModel):
    """会员."""

    name = models.CharField(max_length=100, verbose_name='姓名')
    phone = models.CharField(max_length=20, verbose_name='手机号')
    password = models.CharField(
        max_length=128,
        default='',
        verbose_name='密码',
        help_text='哈希密码，禁止在 API 响应中暴露',
    )
    token = models.CharField(
        max_length=128,
        blank=True,
        default='',
        verbose_name='登录令牌',
        help_text='哈希令牌，禁止在 API 响应中暴露',
    )
    token_created_at = models.DateTimeField(null=True, blank=True, verbose_name='令牌创建时间')
    card_no = models.CharField(max_length=50, blank=True, default='', verbose_name='会员卡号')
    points = models.IntegerField(default=0, verbose_name='积分')
    balance = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='储值余额')
    total_spent = models.DecimalField(max_digits=12, decimal_places=2, default=0, verbose_name='累计消费')
    remark = models.TextField(blank=True, default='', verbose_name='备注')

    class Meta:
        db_table = 'member'
        verbose_name = '会员'
        ordering = ['-created_at']
        constraints = [
            models.UniqueConstraint(fields=['tenant', 'phone'], name='uq_member_tenant_phone'),
        ]
        indexes = [
            models.Index(fields=['tenant', 'token'], name='idx_member_tenant_token'),
        ]

    def __str__(self):
        return f'{self.name} ({self.phone})'

    def is_token_valid(self):
        """检查 token 是否在 30 天有效期内."""
        if not self.token or not self.token_created_at:
            return False
        return timezone.now() < self.token_created_at + timedelta(days=30)
