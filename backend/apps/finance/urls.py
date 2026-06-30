from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import DailySummaryViewSet

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/daily-summaries', DailySummaryViewSet, basename='daily-summary')

urlpatterns = [path('', include(router.urls))]
