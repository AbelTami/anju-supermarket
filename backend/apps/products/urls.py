"""Product URL routes."""
from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CategoryViewSet, ProductViewSet

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/categories', CategoryViewSet, basename='category')
router.register(r'(?P<tenant_slug>[^/.]+)/products', ProductViewSet, basename='product')

urlpatterns = [
    path('', include(router.urls)),
]
