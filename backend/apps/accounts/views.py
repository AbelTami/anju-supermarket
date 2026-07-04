"""Auth views — login, register, token refresh."""
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from .models import User
from .serializers import CustomTokenObtainPairSerializer, RegisterSerializer


class LoginView(TokenObtainPairView):
    """POST /api/auth/login/ — JWT login with tenant info."""
    serializer_class = CustomTokenObtainPairSerializer
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'login'


class RefreshView(TokenRefreshView):
    """POST /api/auth/refresh/ — refresh access token."""
    permission_classes = [AllowAny]


class RegisterView(APIView):
    """POST /api/auth/register/ — 自助注册超市+管理员."""
    permission_classes = [AllowAny]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'login'

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        result = serializer.save()

        # Generate tokens for immediate login after registration
        refresh = RefreshToken.for_user(result['user'])
        return Response({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'id': result['user'].id,
                'username': result['user'].username,
            },
            'tenant': {
                'id': result['tenant'].id,
                'name': result['tenant'].name,
                'slug': result['tenant'].slug,
            },
        }, status=status.HTTP_201_CREATED)


class ProfileView(APIView):
    """GET /api/auth/profile/ — current user profile."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        return Response({
            'id': request.user.id,
            'username': request.user.username,
            'phone': request.user.phone,
            'email': request.user.email,
            'tenants': [
                {'id': t.id, 'name': t.name, 'slug': t.slug}
                for t in request.user.tenants.filter(is_active=True)
            ],
        })


class ChangePasswordView(APIView):
    """POST /api/auth/change-password/ — change current user's password."""
    permission_classes = [IsAuthenticated]
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'login'

    def post(self, request):
        current = request.data.get('current_password', '')
        new = request.data.get('new_password', '')

        if not request.user.check_password(current):
            return Response({'error': '当前密码不正确'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            validate_password(new, user=request.user)
        except ValidationError as e:
            return Response({'error': '; '.join(e.messages)}, status=status.HTTP_400_BAD_REQUEST)

        request.user.set_password(new)
        request.user.save()
        return Response({'success': True})
