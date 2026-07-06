from django.urls import path

from .views import TenantDetailView, TenantPublicView

urlpatterns = [
    path('<slug:tenant_slug>/info/', TenantPublicView.as_view(), name='tenant-public'),
    path('<slug:tenant_slug>/', TenantDetailView.as_view(), name='tenant-detail'),
]
