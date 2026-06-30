from rest_framework import serializers

from .models import DailySummary


class DailySummarySerializer(serializers.ModelSerializer):
    class Meta:
        model = DailySummary
        fields = '__all__'
        read_only_fields = ['id', 'tenant']


class FinanceOverviewSerializer(serializers.Serializer):
    """Aggregated finance overview — computed, not stored."""
    date = serializers.DateField()
    total_orders = serializers.IntegerField()
    total_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    cash_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    wechat_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
    alipay_amount = serializers.DecimalField(max_digits=12, decimal_places=2)
