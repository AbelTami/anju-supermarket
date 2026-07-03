"""Employee serializers."""
from rest_framework import serializers

from apps.accounts.models import User, UserTenant


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
        role_map = {
            'super_admin': '超级管理员',
            'manager': '店长',
            'cashier': '收银员',
            'warehouse': '库管',
            'accountant': '财务',
        }
        return role_map.get(self._role_val(obj), '')


class EmployeeAddSerializer(serializers.Serializer):
    """Add an existing user to the current tenant with a role."""
    username = serializers.CharField()
    role = serializers.ChoiceField(choices=[
        ('super_admin', '超级管理员'),
        ('manager', '店长'),
        ('cashier', '收银员'),
        ('warehouse', '库管'),
        ('accountant', '财务'),
    ])

    def create(self, validated_data):
        tenant = self.context['request'].tenant
        request_user = self.context['request'].user
        username = validated_data['username']
        role = validated_data['role']

        # Only super_admin can assign the super_admin role
        if role == 'super_admin':
            current_role = (
                UserTenant.objects
                .filter(user=request_user, tenant=tenant)
                .values_list('role', flat=True)
                .first()
            )
            if current_role != 'super_admin':
                raise serializers.ValidationError({'role': '只有超级管理员才能设置超级管理员角色'})

        user = User.objects.filter(username=username).first()
        if not user:
            raise serializers.ValidationError({'username': '用户不存在'})

        if UserTenant.objects.filter(user=user, tenant=tenant).exists():
            raise serializers.ValidationError({'username': '该用户已是超市员工'})

        UserTenant.objects.create(user=user, tenant=tenant, role=role)
        return user
