"""Auth & user serializers."""
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import User, UserTenant
from apps.tenants.models import Tenant


class CustomTokenObtainPairSerializer(TokenObtainPairSerializer):
    """JWT login — adds tenant info to token payload."""

    def validate(self, attrs):
        data = super().validate(attrs)
        user = self.user
        data['user'] = UserBriefSerializer(user).data
        data['tenants'] = TenantBriefSerializer(
            user.tenants.filter(is_active=True), many=True
        ).data
        return data


class UserBriefSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'phone', 'email', 'first_name']


class TenantBriefSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tenant
        fields = ['id', 'name', 'slug']


class RegisterSerializer(serializers.Serializer):
    """自助注册 — 创建超市 + 管理员."""

    tenant_name = serializers.CharField(max_length=200, label='超市名称')
    username = serializers.CharField(max_length=150)
    password = serializers.CharField(min_length=6, write_only=True)
    phone = serializers.CharField(max_length=20, required=False, allow_blank=True)

    def create(self, validated_data):
        tenant_name = validated_data['tenant_name']
        # Generate slug
        from apps.tenants.models import generate_slug
        slug = generate_slug(tenant_name)

        # ponytail: reuse Django's create_user, don't hand-roll hashing
        user = User.objects.create_user(
            username=validated_data['username'],
            password=validated_data['password'],
            phone=validated_data.get('phone', ''),
        )

        tenant = Tenant.objects.create(name=tenant_name, slug=slug)

        UserTenant.objects.create(
            user=user,
            tenant=tenant,
            role='super_admin',
        )

        return {
            'user': user,
            'tenant': tenant,
        }
