"""库存管理 — 入库/出库/盘点."""
from common.models import TenantAwareModel
from django.db import models


class InventoryRecord(TenantAwareModel):
    """库存变动流水."""

    class Type(models.TextChoices):
        PURCHASE_IN = 'purchase_in', '采购入库'
        RETURN_IN = 'return_in', '退货入库'
        CHECK_IN = 'check_in', '盘盈入库'
        SALE_OUT = 'sale_out', '销售出库'
        DAMAGE_OUT = 'damage_out', '报损出库'
        CHECK_OUT = 'check_out', '盘亏出库'

    sku = models.ForeignKey('products.ProductSKU', on_delete=models.CASCADE, related_name='inventory_records', verbose_name='商品SKU')
    type = models.CharField(max_length=20, choices=Type.choices, verbose_name='变动类型')
    quantity = models.DecimalField(max_digits=12, decimal_places=3, verbose_name='数量')
    before_quantity = models.DecimalField(max_digits=12, decimal_places=3, default=0, verbose_name='变动前数量')
    after_quantity = models.DecimalField(max_digits=12, decimal_places=3, default=0, verbose_name='变动后数量')
    remark = models.TextField(blank=True, default='', verbose_name='备注')
    operator = models.ForeignKey('accounts.User', on_delete=models.PROTECT, verbose_name='操作人')

    class Meta:
        db_table = 'inventory_record'
        verbose_name = '库存流水'


class StockCheck(TenantAwareModel):
    """盘点单."""

    class Status(models.TextChoices):
        DRAFT = 'draft', '草稿'
        CHECKING = 'checking', '盘点中'
        DONE = 'done', '已完成'

    status = models.CharField(max_length=20, choices=Status.choices, default=Status.DRAFT, verbose_name='状态')
    remark = models.TextField(blank=True, default='', verbose_name='备注')
    created_by = models.ForeignKey('accounts.User', on_delete=models.PROTECT, verbose_name='创建人')

    class Meta:
        db_table = 'stock_check'
        verbose_name = '盘点单'
