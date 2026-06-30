"""租户(Tenant) — 每个超市是一个租户."""
import re
from django.db import models
from django.utils.crypto import get_random_string


def generate_slug(name: str) -> str:
    """从中文名称生成拼音缩写的租户 slug."""
    # Fallback: random slug for Chinese names
    base = 't' + get_random_string(6).lower()
    return base


class Tenant(models.Model):
    """超市租户."""

    name = models.CharField(max_length=200, verbose_name='超市名称')
    slug = models.CharField(max_length=50, unique=True, verbose_name='标识符')
    logo = models.ImageField(upload_to='tenants/logos/', null=True, blank=True, verbose_name='Logo')
    address = models.TextField(blank=True, default='', verbose_name='地址')
    phone = models.CharField(max_length=20, blank=True, default='', verbose_name='联系电话')
    business_hours = models.CharField(max_length=100, blank=True, default='', verbose_name='营业时间')
    is_active = models.BooleanField(default=True, verbose_name='启用')
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='注册时间')

    class Meta:
        db_table = 'tenant'
        verbose_name = '租户'
        verbose_name_plural = verbose_name

    def __str__(self):
        return self.name
