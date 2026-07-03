"""Product views — list, detail, create/update/delete."""
import html
import re
from urllib.parse import urlparse

import requests

from common.permissions import IsTenantUser
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.filters import OrderingFilter, SearchFilter
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import Category, Product
from .serializers import (
    CategorySerializer,
    CategoryTreeSerializer,
    ProductDetailSerializer,
    ProductListSerializer,
    ProductWriteSerializer,
)

OPEN_FOOD_FACTS_URL = 'https://world.openfoodfacts.org/api/v2/product/'


class CategoryViewSet(viewsets.ModelViewSet):
    """GET /api/{tenant}/categories/ — CRUD for product categories."""

    def get_permissions(self):
        if self.action in ('list', 'retrieve'):
            return [IsTenantUser()]
        return [IsAuthenticated(), IsTenantUser()]

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
        return [IsAuthenticated(), IsTenantUser()]

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

    @action(detail=False, methods=['get'], url_path='barcode-lookup', permission_classes=[IsAuthenticated])
    def barcode_lookup(self, request, *args, **kwargs):
        """GET /{slug}/products/barcode-lookup/?barcode=xxx — query Open Food Facts by barcode."""
        barcode = request.query_params.get('barcode', '').strip()
        if not barcode:
            return Response({'error': '请提供条码'}, status=status.HTTP_400_BAD_REQUEST)
        if not re.match(r'^[0-9]{8,14}$', barcode):
            return Response({'error': '无效条码'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            resp = requests.get(f'{OPEN_FOOD_FACTS_URL}{barcode}.json', timeout=5,
                                headers={'User-Agent': 'AnjuSupermarket/1.0'})
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
