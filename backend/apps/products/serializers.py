"""Product serializers."""
from rest_framework import serializers

from .models import Category, Product, ProductSKU


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ['id', 'name', 'parent', 'sort_order']


class CategoryTreeSerializer(CategorySerializer):
    """Category with children — used only for category listing."""
    children = serializers.SerializerMethodField()

    class Meta(CategorySerializer.Meta):
        fields = CategorySerializer.Meta.fields + ['children']

    def get_children(self, obj):
        qs = obj.children.all() if hasattr(obj, 'children') else Category.objects.filter(parent=obj)
        return CategoryTreeSerializer(qs, many=True).data if qs.exists() else []


class ProductSKUSerializer(serializers.ModelSerializer):
    class Meta:
        model = ProductSKU
        fields = ['id', 'barcode', 'spec_name', 'spec_attrs', 'purchase_price', 'selling_price', 'stock_quantity', 'stock_alert']


class ProductListSerializer(serializers.ModelSerializer):
    """Product list — flat with category name."""
    category_name = serializers.CharField(source='category.name', read_only=True, default='')
    sku_count = serializers.IntegerField(source='skus.count', read_only=True, default=0)

    class Meta:
        model = Product
        fields = ['id', 'name', 'category_name', 'unit', 'image', 'is_weighted', 'is_active', 'sku_count', 'created_at']


class ProductDetailSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    skus = ProductSKUSerializer(many=True, read_only=True)

    class Meta:
        model = Product
        fields = ['id', 'name', 'category', 'unit', 'image', 'is_weighted', 'is_active', 'skus', 'created_at', 'updated_at']


class ProductWriteSerializer(serializers.ModelSerializer):
    skus = ProductSKUSerializer(many=True)

    class Meta:
        model = Product
        fields = ['name', 'category', 'unit', 'image', 'is_weighted', 'is_active', 'skus']

    def create(self, validated_data):
        skus_data = validated_data.pop('skus', [])
        validated_data['tenant'] = self.context['request'].tenant
        product = Product.objects.create(**validated_data)
        for sku_data in skus_data:
            sku_data['tenant'] = product.tenant
            ProductSKU.objects.create(product=product, **sku_data)
        return product
