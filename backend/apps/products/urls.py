"""Product URL routes."""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CategoryViewSet, ProductSKUViewSet, ProductViewSet

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/categories', CategoryViewSet, basename='category')
router.register(r'(?P<tenant_slug>[^/.]+)/products', ProductViewSet, basename='product')
router.register(r'(?P<tenant_slug>[^/.]+)/skus', ProductSKUViewSet, basename='sku')

urlpatterns = [
    path('', include(router.urls)),
]
