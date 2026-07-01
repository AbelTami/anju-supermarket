from django.urls import include, path
from rest_framework.routers import DefaultRouter

from .auth_views import MemberLoginView, MemberProfileView
from .views import MemberViewSet

router = DefaultRouter()
router.register(r'(?P<tenant_slug>[^/.]+)/members', MemberViewSet, basename='member')

urlpatterns = [
    path('<slug:tenant_slug>/members/login/', MemberLoginView.as_view(), name='member-login'),
    path('<slug:tenant_slug>/members/profile/', MemberProfileView.as_view(), name='member-profile'),
    path('', include(router.urls)),
]
