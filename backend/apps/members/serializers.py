"""Member serializers."""
from rest_framework import serializers

from .models import Member


class MemberSerializer(serializers.ModelSerializer):
    class Meta:
        model = Member
        fields = ['id', 'name', 'phone', 'card_no', 'points', 'balance', 'total_spent', 'remark', 'created_at']
        read_only_fields = ['id', 'created_at', 'tenant']
