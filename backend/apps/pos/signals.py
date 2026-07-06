"""Signal handlers for POS app — publish new orders via SSE."""
import logging

from django.db.models.signals import post_save
from django.dispatch import receiver

from .models import Order

logger = logging.getLogger(__name__)


@receiver(post_save, sender=Order)
def publish_new_order(sender, instance, created, **kwargs):
    """When a new order is created, publish to SSE subscribers.

    SSE is best-effort: a failure here must not roll the order back. But silent
    `except: pass` hides real outages, so we log instead.
    """
    if not created:
        return
    try:
        from common.sse import publish
        payload = {
            "id": instance.id,
            "order_no": instance.order_no,
            "total_amount": str(instance.total_amount),
            "paid_amount": str(instance.paid_amount),
            "payment_method": instance.payment_method,
            "cashier_name": instance.cashier.username if instance.cashier else "",
            "paid_at": instance.paid_at.isoformat(),
        }
        publish(instance.tenant_id, "new_order", payload)
    except Exception:
        logger.exception("SSE publish failed for order %s", instance.id)
