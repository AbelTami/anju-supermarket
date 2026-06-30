from rest_framework import serializers

from .models import Tenant


class TenantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Tenant
        fields = ['id', 'name', 'slug', 'phone', 'address', 'business_hours', 'is_active']
        read_only_fields = ['id', 'slug']
