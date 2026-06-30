"""Product views — list, detail, create/update/delete."""
from common.permissions import TenantAccessPermission
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import viewsets
from rest_framework.filters import OrderingFilter, SearchFilter

from .models import Category, Product
from .serializers import (
    CategorySerializer,
    CategoryTreeSerializer,
    ProductDetailSerializer,
    ProductListSerializer,
    ProductWriteSerializer,
)


class CategoryViewSet(viewsets.ModelViewSet):
    """GET /api/{tenant}/categories/ — CRUD for product categories."""
    permission_classes = [TenantAccessPermission]

    def get_serializer_class(self):
        if self.action == 'list':
            return CategoryTreeSerializer
        return CategorySerializer

    def get_queryset(self):
        return Category.objects.filter(tenant=self.request.tenant)

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)


class ProductViewSet(viewsets.ModelViewSet):
    """GET /api/{tenant}/products/ — CRUD for products."""
    permission_classes = [TenantAccessPermission]
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'is_active', 'is_weighted']
    search_fields = ['name', 'skus__barcode']
    ordering_fields = ['name', 'created_at']

    def get_queryset(self):
        return Product.objects.filter(tenant=self.request.tenant).prefetch_related('skus')

    def get_serializer_class(self):
        if self.action == 'list' and self.request.query_params.get('skus') == '1':
            return ProductDetailSerializer
        if self.action in ('list',):
            return ProductListSerializer
        if self.action in ('create', 'update', 'partial_update'):
            return ProductWriteSerializer
        return ProductDetailSerializer

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)
