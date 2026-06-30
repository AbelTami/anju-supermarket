from django.urls import path

from .views import TenantDetailView

urlpatterns = [
    path('<slug:tenant_slug>/', TenantDetailView.as_view(), name='tenant-detail'),
]
