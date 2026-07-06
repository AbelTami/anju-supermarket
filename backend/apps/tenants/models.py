"""租户(Tenant) — 每个超市是一个租户."""
import re
from django.db import models


def generate_slug(name: str) -> str:
    """Generate a unique tenant slug with collision retry."""
    import random
    import string

    for _ in range(10):
        candidate = 't' + ''.join(random.choices(string.ascii_lowercase + string.digits, k=6))
        if not Tenant.objects.filter(slug=candidate).exists():
            return candidate
    raise RuntimeError('Unable to generate a unique tenant slug after 10 attempts.')


class Tenant(models.Model):
    """超市租户."""

    class BroadcastSeverity(models.TextChoices):
        INFO = 'info', '通知'
        WARNING = 'warning', '注意'
        ERROR = 'error', '紧急'

    name = models.CharField(max_length=200, verbose_name='超市名称')
    slug = models.CharField(max_length=50, unique=True, verbose_name='标识符')
    logo = models.ImageField(upload_to='tenants/logos/', null=True, blank=True, verbose_name='Logo')
    address = models.TextField(blank=True, default='', verbose_name='地址')
    phone = models.CharField(max_length=20, blank=True, default='', verbose_name='联系电话')
    business_hours = models.CharField(max_length=100, blank=True, default='', verbose_name='营业时间')
    is_active = models.BooleanField(default=True, verbose_name='启用')
    # ponytail: operational broadcast — single active banner per tenant.
    # History/scheduling is YAGNI; add a separate model if either is needed.
    broadcast_active = models.BooleanField(default=False, verbose_name='广播启用')
    broadcast_message = models.CharField(max_length=200, blank=True, default='', verbose_name='广播内容')
    broadcast_severity = models.CharField(
        max_length=10, choices=BroadcastSeverity.choices,
        default=BroadcastSeverity.WARNING, verbose_name='广播级别',
    )
    # ponytail: printer template — set once, rarely changed
    paper_width = models.CharField(
        max_length=3, choices=[('58', '58mm'), ('80', '80mm')],
        default='58', verbose_name='纸张宽度',
    )
    print_logo = models.BooleanField(default=True, verbose_name='打印Logo')
    print_barcode = models.BooleanField(default=True, verbose_name='打印条码')
    footer_text = models.TextField(blank=True, default='', verbose_name='页脚文字')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='注册时间')

    class Meta:
        db_table = 'tenant'
        verbose_name = '租户'
        verbose_name_plural = verbose_name

    def __str__(self):
        return self.name
