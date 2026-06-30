"""Shared base models for tenant-aware data."""
from django.db import models


class TenantAwareModel(models.Model):
    """Base model for all tenant-scoped data. Every app model inherits this."""

    tenant = models.ForeignKey(
        'tenants.Tenant',
        on_delete=models.CASCADE,
        related_name='+',
        editable=False,
    )
    created_at = models.DateTimeField(auto_now_add=True, verbose_name='创建时间')
    updated_at = models.DateTimeField(auto_now=True, verbose_name='更新时间')

    class Meta:
        abstract = True
        indexes = [
            models.Index(fields=['tenant', '-created_at']),
        ]
