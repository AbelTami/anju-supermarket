"""Member auth views."""
import secrets

from common.permissions import IsTenantUser
from common.token_utils import hash_token, get_member_from_request
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
        raw_token = secrets.token_hex(32)
        member.token = hash_token(raw_token)
        member.token_created_at = timezone.now()
        member.save(update_fields=['token', 'token_created_at'])

        return Response({
            'token': raw_token,
            'member': serializer.data,
        }, status=status.HTTP_200_OK)


class MemberProfileView(APIView):
    """会员个人中心 — 通过 Authorization header 中的 token 认证."""

    permission_classes = [IsTenantUser]
    authentication_classes = []

    def get(self, request, *args, **kwargs):
        member = get_member_from_request(request)
        if not member:
            return Response({'error': '未提供认证令牌或令牌无效'}, status=status.HTTP_401_UNAUTHORIZED)

        if not member.is_token_valid():
            return Response({'error': '令牌已过期，请重新登录'}, status=status.HTTP_401_UNAUTHORIZED)

        return Response(
            MemberSerializer(member, context={'show_full_phone': True}).data,
            status=status.HTTP_200_OK,
        )
