"""Employee serializers."""
from rest_framework import serializers

from apps.accounts.models import User, UserTenant

ROLE_CHOICES = [
    ('super_admin', '超级管理员'),
    ('manager', '店长'),
    ('cashier', '收银员'),
    ('warehouse', '库管'),
    ('accountant', '财务'),
]
ROLE_LABEL_MAP = dict(ROLE_CHOICES)


def _require_super_admin(tenant, user):
    """Raise ValidationError if user is not super_admin in the given tenant."""
    role = UserTenant.objects.filter(user=user, tenant=tenant).values_list('role', flat=True).first()
    if role != 'super_admin':
        raise serializers.ValidationError({'role': '只有超级管理员才能设置超级管理员角色'})


class EmployeeSerializer(serializers.ModelSerializer):
    role = serializers.SerializerMethodField()
    role_label = serializers.SerializerMethodField()
    name = serializers.CharField(source='first_name', read_only=True, default='')

    class Meta:
        model = User
        fields = ['id', 'username', 'name', 'phone', 'is_active', 'role', 'role_label', 'date_joined']

    def _role_val(self, obj):
        return getattr(obj, '_role', '') or ''

    def get_role(self, obj):
        return self._role_val(obj)

    def get_role_label(self, obj):
        return ROLE_LABEL_MAP.get(self._role_val(obj), '')


class EmployeeUpdateSerializer(serializers.Serializer):
    """Update employee role and active status within current tenant."""
    role = serializers.ChoiceField(required=False, choices=ROLE_CHOICES)
    is_active = serializers.BooleanField(required=False)

    def update(self, instance, validated_data):
        tenant = self.context['request'].tenant
        request_user = self.context['request'].user
        role = validated_data.get('role')
        is_active = validated_data.get('is_active')

        # Prevent self-deactivation
        if is_active is False and instance == request_user:
            raise serializers.ValidationError({'is_active': '不能停用自己的账号'})

        if role:
            if role == 'super_admin':
                _require_super_admin(tenant, request_user)

            UserTenant.objects.update_or_create(
                user=instance, tenant=tenant,
                defaults={'role': role},
            )

        if is_active is not None:
            # Prevent deactivating the last active super_admin in the tenant
            if is_active is False:
                target_role = (
                    UserTenant.objects
                    .filter(user=instance, tenant=tenant)
                    .values_list('role', flat=True)
                    .first()
                )
                if target_role == 'super_admin':
                    other_active = (
                        UserTenant.objects
                        .filter(tenant=tenant, role='super_admin', user__is_active=True)
                        .exclude(user=instance)
                        .exists()
                    )
                    if not other_active:
                        raise serializers.ValidationError(
                            {'is_active': '不能停用最后一位超级管理员'}
                        )

            instance.is_active = is_active
            instance.save(update_fields=['is_active'])

        return instance


class EmployeeAddSerializer(serializers.Serializer):
    """Add an existing user to the current tenant with a role."""
    username = serializers.CharField()
    role = serializers.ChoiceField(choices=ROLE_CHOICES)

    def create(self, validated_data):
        tenant = self.context['request'].tenant
        request_user = self.context['request'].user
        username = validated_data['username']
        role = validated_data['role']

        if role == 'super_admin':
            _require_super_admin(tenant, request_user)

        user = User.objects.filter(username=username).first()
        if not user:
            raise serializers.ValidationError({'username': '用户不存在'})

        if UserTenant.objects.exclude(tenant=tenant).filter(user=user).exists():
            raise serializers.ValidationError({'username': '该用户已属于其他超市，无法添加'})

        if UserTenant.objects.filter(user=user, tenant=tenant).exists():
            raise serializers.ValidationError({'username': '该用户已是超市员工'})

        UserTenant.objects.create(user=user, tenant=tenant, role=role)
        return user
