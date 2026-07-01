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
    """Product list — flat with category name and min price from SKUs."""
    category_name = serializers.CharField(source='category.name', read_only=True, default='')
    sku_count = serializers.IntegerField(source='skus.count', read_only=True, default=0)
    price = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name', 'category', 'category_name', 'price', 'unit', 'image', 'image_url', 'is_weighted', 'is_active', 'sku_count', 'created_at']

    def get_price(self, obj):
        # Return the lowest selling price among SKUs
        prices = [s.selling_price for s in obj.skus.all() if s.selling_price > 0]
        return min(prices) if prices else 0


class ProductDetailSerializer(serializers.ModelSerializer):
    category = CategorySerializer(read_only=True)
    skus = ProductSKUSerializer(many=True, read_only=True)
    price = serializers.SerializerMethodField()

    class Meta:
        model = Product
        fields = ['id', 'name', 'category', 'price', 'unit', 'image', 'image_url', 'is_weighted', 'is_active', 'skus', 'created_at', 'updated_at']

    def get_price(self, obj):
        prices = [s.selling_price for s in obj.skus.all() if s.selling_price > 0]
        return min(prices) if prices else 0


class ProductWriteSerializer(serializers.ModelSerializer):
    skus = ProductSKUSerializer(many=True)

    class Meta:
        model = Product
        fields = ['name', 'category', 'unit', 'image', 'image_url', 'is_weighted', 'is_active', 'skus']

    def create(self, validated_data):
        skus_data = validated_data.pop('skus', [])
        validated_data['tenant'] = self.context['request'].tenant
        product = Product.objects.create(**validated_data)
        for sku_data in skus_data:
            sku_data['tenant'] = product.tenant
            ProductSKU.objects.create(product=product, **sku_data)
        return product
