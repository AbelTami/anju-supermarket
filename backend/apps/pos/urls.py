from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import OrderViewSet
from .sse_views import order_sse_view

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/orders', OrderViewSet, basename='order')

urlpatterns = [
    path('<slug:tenant_slug>/orders/stream/', order_sse_view, name='order-sse'),
    path('', include(router.urls)),
]
