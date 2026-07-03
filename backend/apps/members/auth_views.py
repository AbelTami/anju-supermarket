"""Member auth views."""
import secrets

from common.permissions import IsTenantUser
from django.utils import timezone
from rest_framework import status
from rest_framework.response import Response
from rest_framework.throttling import ScopedRateThrottle
from rest_framework.views import APIView

from .auth_serializers import MemberLoginSerializer
from .models import Member
from .serializers import MemberSerializer


class MemberLoginView(APIView):
    """会员登录 — 手机号 + 密码，返回会员信息和一个简单 token."""

    permission_classes = [IsTenantUser]
    authentication_classes = []
    throttle_classes = [ScopedRateThrottle]
    throttle_scope = 'login'

    def post(self, request, *args, **kwargs):
        serializer = MemberLoginSerializer(
            data=request.data,
            context={'tenant': request.tenant},
        )
        serializer.is_valid(raise_exception=True)

        member = serializer.validated_data['member']
        token = secrets.token_hex(32)
        member.token = token
        member.token_created_at = timezone.now()
        member.save(update_fields=['token', 'token_created_at'])

        return Response({
            'token': token,
            'member': serializer.data,
        }, status=status.HTTP_200_OK)


class MemberProfileView(APIView):
    """会员个人中心 — 通过 Authorization header 中的 token 认证."""

    permission_classes = [IsTenantUser]
    authentication_classes = []

    def get(self, request, *args, **kwargs):
        auth_header = request.headers.get('Authorization', '')
        if not auth_header.startswith('Token '):
            return Response({'error': '未提供认证令牌'}, status=status.HTTP_401_UNAUTHORIZED)

        token = auth_header[6:]

        try:
            member = Member.objects.get(token=token, tenant=request.tenant)
        except Member.DoesNotExist:
            return Response({'error': '令牌无效或已过期'}, status=status.HTTP_401_UNAUTHORIZED)

        if not member.is_token_valid():
            return Response({'error': '令牌已过期，请重新登录'}, status=status.HTTP_401_UNAUTHORIZED)

        return Response(
            MemberSerializer(member, context={'show_full_phone': True}).data,
            status=status.HTTP_200_OK,
        )
