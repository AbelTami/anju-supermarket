"""Root URL configuration for 安居超市管理系统."""
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/auth/', include('apps.accounts.urls')),
    path('api/', include('apps.tenants.urls')),
    path('api/', include('apps.products.urls')),
    path('api/', include('apps.inventory.urls')),
    path('api/', include('apps.pos.urls')),
    path('api/', include('apps.members.urls')),
    path('api/', include('apps.suppliers.urls')),
    path('api/', include('apps.employees.urls')),
    path('api/', include('apps.finance.urls')),
]
