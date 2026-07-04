from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .views import CouponViewSet, MemberCouponViewSet

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/coupons', CouponViewSet, basename='coupon')
router.register(r'(?P<tenant_slug>[^/.]+)/member-coupons', MemberCouponViewSet, basename='member-coupon')

urlpatterns = [path('', include(router.urls))]
