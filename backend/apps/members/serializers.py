"""Member serializers."""
from django.contrib.auth.hashers import make_password
from rest_framework import serializers

from .models import Member


class MemberSerializer(serializers.ModelSerializer):
    phone = serializers.SerializerMethodField()

    class Meta:
        model = Member
        fields = ['id', 'name', 'phone', 'password', 'card_no', 'points', 'balance', 'total_spent', 'remark', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']
        extra_kwargs = {
            'password': {'write_only': True, 'required': False, 'allow_blank': True},
        }

    def get_phone(self, obj):
        """Return full phone for staff; mask for non-employees."""
        request = self.context.get('request')
        # Context override — member viewing own profile
        if self.context.get('show_full_phone'):
            return obj.phone
        # Staff members (authenticated users with a role in this tenant) see full phone
        if request and request.user.is_authenticated:
            from apps.accounts.models import UserTenant
            is_employee = UserTenant.objects.filter(
                user=request.user, tenant=obj.tenant
            ).exists()
            if is_employee:
                return obj.phone
        # Mask for everyone else (anonymous, member token, etc.)
        return self._mask_phone(obj.phone)

    @staticmethod
    def _mask_phone(phone):
        """Mask middle digits of a phone number: 138****0001."""
        if not phone or len(phone) < 7:
            return phone
        return phone[:3] + '****' + phone[-4:]

    def create(self, validated_data):
        password = validated_data.pop('password', None)
        if password:
            validated_data['password'] = make_password(password)
        return super().create(validated_data)

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        if password:
            validated_data['password'] = make_password(password)
        return super().update(instance, validated_data)
