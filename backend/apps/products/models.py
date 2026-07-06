"""商品管理 — 多级分类、SPU、SKU."""
from common.models import TenantAwareModel
from django.db import models


class Category(TenantAwareModel):
    """商品分类 (多级)."""

    name = models.CharField(max_length=100, verbose_name='分类名称')
    parent = models.ForeignKey('self', on_delete=models.CASCADE, null=True, blank=True, related_name='children', verbose_name='上级分类')
    sort_order = models.IntegerField(default=0, verbose_name='排序')

    class Meta:
        db_table = 'product_category'
        verbose_name = '商品分类'
        indexes = [
            models.Index(fields=['tenant', 'parent_id'], name='idx_category_tenant_parent'),
        ]

    def __str__(self):
        return self.name


class Product(TenantAwareModel):
    """商品 SPU."""

    name = models.CharField(max_length=200, verbose_name='商品名称')
    category = models.ForeignKey(Category, on_delete=models.SET_NULL, null=True, blank=True, related_name='products', verbose_name='分类')
    image = models.ImageField(upload_to='products/', null=True, blank=True, verbose_name='商品图片')
    image_url = models.URLField(max_length=500, blank=True, default='', verbose_name='远程图片地址')
    unit = models.CharField(max_length=20, default='个', verbose_name='单位')
    is_weighted = models.BooleanField(default=False, verbose_name='称重商品')
    is_active = models.BooleanField(default=True, verbose_name='上架')

    class Meta:
        db_table = 'product'
        verbose_name = '商品'
        ordering = ['-created_at']

    def __str__(self):
        return self.name


class ProductSKU(TenantAwareModel):
    """商品 SKU — 每个规格独立条码和库存."""

    product = models.ForeignKey(Product, on_delete=models.CASCADE, related_name='skus', verbose_name='所属商品')
    barcode = models.CharField(max_length=100, verbose_name='条码')
    spec_name = models.CharField(max_length=200, default='默认', verbose_name='规格名称')
    spec_attrs = models.JSONField(default=dict, verbose_name='规格属性')  # flat dict of str→str; validate at serializer level
    purchase_price = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='进货价')
    selling_price = models.DecimalField(max_digits=10, decimal_places=2, default=0, verbose_name='零售价')
    stock_quantity = models.DecimalField(max_digits=12, decimal_places=3, default=0, verbose_name='当前库存')
    stock_alert = models.DecimalField(max_digits=12, decimal_places=3, default=0, verbose_name='库存预警值')

    class Meta:
        db_table = 'product_sku'
        verbose_name = '商品SKU'
        ordering = ['product', 'spec_name']
        constraints = [
            models.UniqueConstraint(fields=['tenant', 'barcode'], name='uq_tenant_barcode'),
            models.CheckConstraint(condition=models.Q(purchase_price__gte=0), name='chk_sku_purchase_nonneg'),
            models.CheckConstraint(condition=models.Q(selling_price__gte=0), name='chk_sku_selling_nonneg'),
            models.CheckConstraint(condition=models.Q(stock_quantity__gte=0), name='chk_sku_stock_nonneg'),
            models.CheckConstraint(condition=models.Q(stock_alert__gte=0), name='chk_sku_alert_nonneg'),
        ]

    def __str__(self):
        return f'{self.product.name} - {self.spec_name}'
