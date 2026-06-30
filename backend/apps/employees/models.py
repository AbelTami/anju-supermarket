"""员工管理 — 复用 accounts.User，此处仅扩展考勤等."""
from common.models import TenantAwareModel
from django.db import models


class Shift(TenantAwareModel):
    """排班记录 — ponytail: simplest model that captures shift data."""

    user = models.ForeignKey('accounts.User', on_delete=models.CASCADE, verbose_name='员工')
    start_time = models.DateTimeField(verbose_name='上班时间')
    end_time = models.DateTimeField(null=True, blank=True, verbose_name='下班时间')

    class Meta:
        db_table = 'employee_shift'
        verbose_name = '排班'
