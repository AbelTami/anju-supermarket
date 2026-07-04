"""Member serializers."""
from django.contrib.auth.hashers import make_password
from rest_framework import serializers

from apps.accounts.models import UserTenant
from .models import Member


class MemberWriteSerializer(serializers.ModelSerializer):
    """Used for create/update — phone is writable."""

    class Meta:
        model = Member
        fields = ['id', 'name', 'phone', 'password', 'card_no', 'points', 'balance', 'total_spent', 'remark', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']
        extra_kwargs = {
            'password': {'write_only': True, 'required': False, 'allow_blank': True},
        }

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


class MemberSerializer(MemberWriteSerializer):
    """Read serializer — masks phone for non-staff."""

    def to_representation(self, instance):
        data = super().to_representation(instance)
        data['phone'] = self._mask_phone_for_context(instance)
        return data

    def _mask_phone_for_context(self, obj):
        request = self.context.get('request')
        if self.context.get('show_full_phone'):
            return obj.phone
        if request and request.user and request.user.is_authenticated:
            if UserTenant.objects.filter(user=request.user, tenant=obj.tenant).exists():
                return obj.phone
        return self._mask_phone(obj.phone)

    @staticmethod
    def _mask_phone(phone):
        if not phone or len(phone) < 7:
            return phone
        return phone[:3] + '****' + phone[-4:]
