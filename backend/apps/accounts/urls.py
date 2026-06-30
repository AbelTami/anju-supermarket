"""Auth URL routes."""
from django.urls import path

from .views import ChangePasswordView, LoginView, ProfileView, RefreshView, RegisterView

urlpatterns = [
    path('login/', LoginView.as_view(), name='auth-login'),
    path('refresh/', RefreshView.as_view(), name='auth-refresh'),
    path('register/', RegisterView.as_view(), name='auth-register'),
    path('profile/', ProfileView.as_view(), name='auth-profile'),
    path('change-password/', ChangePasswordView.as_view(), name='auth-change-password'),
]
