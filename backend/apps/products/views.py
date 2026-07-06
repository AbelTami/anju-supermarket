"""Product views — list, detail, create/update/delete."""
import html
import re
from datetime import timedelta
from urllib.parse import urlparse

import requests
from django.conf import settings
from django.db.models import Q, Sum
from django.utils import timezone

from common.permissions import (
    IsTenantUser,
    IsAdminOrManager,
    IsSuperAdmin,
)
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Category, Product, ProductSKU
from .serializers import (
    CategorySerializer,
    CategoryTreeSerializer,
    ProductDetailSerializer,
    ProductListSerializer,
    ProductSKUSerializer,
    ProductWriteSerializer,
)


class CategoryViewSet(viewsets.ModelViewSet):
    """GET /api/{tenant}/categories/ — CRUD for product categories."""

    def get_permissions(self):
        if self.action in ('list', 'retrieve'):
            return [IsTenantUser()]
        return [IsAuthenticated(), IsTenantUser(), IsAdminOrManager()]

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
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['category', 'is_active', 'is_weighted']
    search_fields = ['name', 'skus__barcode']
    ordering_fields = ['name', 'created_at']

    def get_permissions(self):
        if self.action in ('list', 'retrieve'):
            return [IsTenantUser()]
        elif self.action in ('create', 'update', 'partial_update'):
            return [IsAuthenticated(), IsTenantUser(), IsAdminOrManager()]
        elif self.action == 'destroy':
            return [IsAuthenticated(), IsTenantUser(), IsSuperAdmin()]
        return super().get_permissions()

    def get_queryset(self):
        # ponytail: 30-day sales annotation powers the storefront's
        # "销量优先" sort. Single query with JOIN through SKU → OrderItem →
        # Order; if it ever shows up slow in pg_stat_statements, denormalize
        # to a Product.monthly_sales field refreshed by a cron task.
        recent = timezone.now() - timedelta(days=30)
        qs = (
            Product.objects
            .filter(tenant=self.request.tenant)
            .prefetch_related('skus')
            .annotate(
                monthly_sales=Sum(
                    'skus__orderitem__quantity',
                    filter=Q(skus__orderitem__order__paid_at__gte=recent),
                ),
            )
        )
        # ponytail: customers never see off-shelf products. Admin BFF sends
        # `Authorization: Bearer <jwt>`; storefront BFF sends Token or nothing.
        # One guard at the data layer covers list / retrieve / search.
        auth = self.request.headers.get('Authorization', '')
        if not auth.startswith('Bearer '):
            qs = qs.filter(is_active=True)
        return qs

    def get_serializer_class(self):
        if self.action == 'list' and self.request.query_params.get('skus') == '1':
            return ProductDetailSerializer
        if self.action in ('list',):
            return ProductListSerializer
        if self.action in ('create', 'update', 'partial_update'):
            return ProductWriteSerializer
        return ProductDetailSerializer

    @action(detail=False, methods=['get'], url_path='barcode-lookup', permission_classes=[IsAuthenticated])
    def barcode_lookup(self, request, *args, **kwargs):
        """GET /{slug}/products/barcode-lookup/?barcode=xxx — query Open Food Facts by barcode."""
        barcode = request.query_params.get('barcode', '').strip()
        if not barcode:
            return Response({'error': '请提供条码'}, status=status.HTTP_400_BAD_REQUEST)
        if not re.match(r'^[0-9]{8,14}$', barcode):
            return Response({'error': '无效条码'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            resp = requests.get(
                f'{settings.OPEN_FOOD_FACTS_URL}{barcode}.json',
                timeout=5,
                headers={'User-Agent': 'AnjuSupermarket/1.0'},
            )
            resp.raise_for_status()
            data = resp.json()
        except requests.RequestException:
            return Response({'error': '条码查询服务暂不可用'}, status=status.HTTP_502_BAD_GATEWAY)

        if data.get('status') != 1:
            return Response({'found': False, 'message': '未找到该条码的商品信息'})

        product = data['product']
        image_url = product.get('image_url', '')
        if image_url:
            parsed = urlparse(image_url)
            if parsed.scheme not in ('http', 'https'):
                image_url = ''
        return Response({
            'found': True,
            'name': html.escape(product.get('product_name', '')),
            'image_url': image_url,
            'brands': product.get('brands', ''),
            'categories': product.get('categories', ''),
            'quantity': product.get('quantity', ''),
        })

    def perform_create(self, serializer):
        serializer.save(tenant=self.request.tenant)


class ProductSKUViewSet(viewsets.ModelViewSet):
    """CRUD for product SKUs — used by the admin product edit modal to change
    prices / stock without recreating the parent product.

    Only update matters in practice; list/retrieve are auto-exposed by the
    router. Create goes through the nested ProductWriteSerializer, delete is
    intentionally absent to keep SKU lifecycle tied to its product.
    """
    serializer_class = ProductSKUSerializer
    permission_classes = [IsAuthenticated, IsTenantUser, IsAdminOrManager]
    queryset = ProductSKU.objects.all()

    def get_queryset(self):
        return ProductSKU.objects.filter(tenant=self.request.tenant)
