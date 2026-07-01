"""Member auth serializers."""
from django.contrib.auth.hashers import check_password
from rest_framework import serializers

from .models import Member


class MemberLoginSerializer(serializers.Serializer):
    phone = serializers.CharField(max_length=20)
    password = serializers.CharField(max_length=128, write_only=True)

    def validate(self, attrs):
        phone = attrs.get('phone')
        password = attrs.get('password')

        if not phone or not password:
            raise serializers.ValidationError('手机号和密码不能为空')

        tenant = self.context.get('tenant')
        if not tenant:
            raise serializers.ValidationError('无法确定所属超市')

        try:
            member = Member.objects.get(tenant=tenant, phone=phone)
        except Member.DoesNotExist:
            raise serializers.ValidationError('手机号或密码错误')

        if not member.password:
            raise serializers.ValidationError('该会员尚未设置密码，请联系店员')

        if not check_password(password, member.password):
            raise serializers.ValidationError('手机号或密码错误')

        attrs['member'] = member
        return attrs

    def to_representation(self, instance):
        member = instance['member']
        return {
            'id': member.id,
            'name': member.name,
            'phone': member.phone,
            'card_no': member.card_no,
            'points': member.points,
            'balance': str(member.balance),
        }
