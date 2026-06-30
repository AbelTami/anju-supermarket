"""供应商管理."""
from common.models import TenantAwareModel
from django.db import models


class Supplier(TenantAwareModel):
    """供应商."""

    name = models.CharField(max_length=200, verbose_name='供应商名称')
    contact = models.CharField(max_length=100, blank=True, default='', verbose_name='联系人')
    phone = models.CharField(max_length=20, blank=True, default='', verbose_name='联系电话')
    address = models.TextField(blank=True, default='', verbose_name='地址')
    remark = models.TextField(blank=True, default='', verbose_name='备注')

    class Meta:
        db_table = 'supplier'
        verbose_name = '供应商'

    def __str__(self):
        return self.name
