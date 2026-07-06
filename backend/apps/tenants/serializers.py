from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from .models import Tenant


class TenantSerializer(serializers.ModelSerializer):
    """Admin serializer — full tenant fields including broadcast controls."""

    def validate(self, data):
        """Ensure broadcast message is required when broadcast is active."""
        instance = getattr(self, 'instance', None)

        # Determine final broadcast_active value (new data or instance value)
        broadcast_active = data.get('broadcast_active')
        if broadcast_active is None and instance:
            broadcast_active = instance.broadcast_active

        # Determine final broadcast_message value
        broadcast_message = data.get('broadcast_message')
        if broadcast_message is None and instance:
            broadcast_message = instance.broadcast_message
        if broadcast_message is None:
            broadcast_message = ''

        # Require message when broadcast is active
        if broadcast_active and not str(broadcast_message).strip():
            raise ValidationError({'broadcast_message': '启用广播时，广播内容不能为空'})

        return data

    class Meta:
        model = Tenant
        fields = [
            'id', 'name', 'slug', 'phone', 'address', 'business_hours', 'is_active',
            'broadcast_active', 'broadcast_message', 'broadcast_severity',
            'paper_width', 'print_logo', 'print_barcode', 'footer_text',
        ]
        read_only_fields = ['id', 'slug']


class TenantPublicSerializer(serializers.ModelSerializer):
    """Storefront serializer — public fields only, no internal flags like is_active.

    Printer fields are included so the customer-facing receipt print window
    can read paper width, barcode toggle, and footer text without hitting the
    admin API. These are configuration, not secrets.
    """

    class Meta:
        model = Tenant
        fields = ['name', 'slug', 'phone', 'address', 'business_hours',
                  'broadcast_active', 'broadcast_message', 'broadcast_severity',
                  'paper_width', 'print_barcode', 'footer_text']
