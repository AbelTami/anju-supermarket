"""Root URL configuration for 安居超市管理系统."""
from django.conf import settings
from django.conf.urls.static import static
from django.contrib import admin
from django.urls import include, path

urlpatterns = [
    path('api/auth/', include('apps.accounts.urls')),
    path('api/', include('apps.tenants.urls')),
    path('api/', include('apps.products.urls')),
    path('api/', include('apps.inventory.urls')),
    path('api/', include('apps.pos.urls')),
    path('api/', include('apps.members.urls')),
    path('api/', include('apps.suppliers.urls')),
    path('api/', include('apps.employees.urls')),
    path('api/', include('apps.finance.urls')),
    path('api/', include('apps.coupons.urls')),
]

if settings.DEBUG:
    # Django admin — only enabled in DEBUG mode for development
    urlpatterns = [path('admin/', admin.site.urls)] + urlpatterns
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
