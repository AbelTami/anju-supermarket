from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import InventoryRecordViewSet, StockCheckViewSet

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/inventory-records', InventoryRecordViewSet, basename='inventory-record')
router.register(r'(?P<tenant_slug>[^/.]+)/stock-checks', StockCheckViewSet, basename='stock-check')

urlpatterns = [path('', include(router.urls))]
