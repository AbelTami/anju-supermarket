"""Finance views — daily summaries and overview."""
from collections import defaultdict
from datetime import date, timedelta

from common.permissions import IsSuperAdminOrManager, IsTenantUser
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from .models import DailySummary
from .serializers import DailySummarySerializer


class DailySummaryViewSet(viewsets.ReadOnlyModelViewSet):
    permission_classes = [IsAuthenticated, IsTenantUser, IsSuperAdminOrManager]
    serializer_class = DailySummarySerializer

    def get_queryset(self):
        qs = DailySummary.objects.filter(tenant=self.request.tenant)
        days = self.request.query_params.get('days', '7')
        cutoff = date.today() - timedelta(days=int(days))
        return qs.filter(date__gte=cutoff).order_by('-date')

    @action(detail=False, methods=['get'], url_path='overview')
    def overview(self, request, **kwargs):
        """GET /api/{slug}/daily-summaries/overview/?days=7&period=daily|weekly|monthly"""
        from apps.pos.models import Order

        days = int(request.query_params.get('days', '7'))
        period = request.query_params.get('period', 'daily')
        cutoff = date.today() - timedelta(days=days)

        raw_orders = Order.objects.filter(
            tenant=request.tenant,
            paid_at__date__gte=cutoff,
        ).values('paid_at__date', 'total_amount', 'payment_method')

        grouped = defaultdict(lambda: {'amount': 0, 'orders': 0, 'cash': 0, 'wechat': 0, 'alipay': 0, 'member': 0})

        for o in raw_orders:
            d = o['paid_at__date']
            if period == 'weekly':
                key = d.isocalendar()[:2]  # (year, week)
                label = f"{key[0]}-W{key[1]:02d}"
            elif period == 'monthly':
                label = d.strftime('%Y-%m')
            else:
                label = d.isoformat()

            grouped[label]['amount'] += float(o['total_amount'] or 0)
            grouped[label]['orders'] += 1
            pm = o['payment_method']
            if pm in ('cash', 'wechat', 'alipay', 'member_card'):
                grouped[label][pm if pm != 'member_card' else 'member'] += float(o['total_amount'] or 0)

        daily_list = sorted(
            [{'date': k, **v} for k, v in grouped.items()],
            key=lambda x: x['date'],
        )

        return Response({
            'days': days,
            'period': period,
            'total_amount': sum(d['amount'] for d in daily_list),
            'total_orders': sum(d['orders'] for d in daily_list),
            'cash_amount': sum(d['cash'] for d in daily_list),
            'wechat_amount': sum(d['wechat'] for d in daily_list),
            'alipay_amount': sum(d['alipay'] for d in daily_list),
            'member_amount': sum(d['member'] for d in daily_list),
            'daily': daily_list,
        })
