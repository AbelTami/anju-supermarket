"""用户与角色权限模型."""
from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):
    """系统用户 — 通过中间表关联到租户."""

    phone = models.CharField(max_length=20, blank=True, default='', verbose_name='手机号')
    avatar = models.ImageField(upload_to='avatars/', null=True, blank=True, verbose_name='头像')
    tenants = models.ManyToManyField(
        'tenants.Tenant',
        through='UserTenant',
        related_name='users',
        verbose_name='所属超市',
    )

    class Meta:
        db_table = 'user'
        verbose_name = '用户'
        verbose_name_plural = verbose_name


class Role(models.TextChoices):
    SUPER_ADMIN = 'super_admin', '超级管理员'
    MANAGER = 'manager', '店长'
    CASHIER = 'cashier', '收银员'
    WAREHOUSE = 'warehouse', '库管'
    ACCOUNTANT = 'accountant', '财务'


class UserTenant(models.Model):
    """用户-租户关联 — 携带角色信息."""

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    tenant = models.ForeignKey('tenants.Tenant', on_delete=models.CASCADE)
    role = models.CharField(
        max_length=20,
        choices=Role.choices,
        default=Role.CASHIER,
        verbose_name='角色',
    )
    joined_at = models.DateTimeField(auto_now_add=True, verbose_name='加入时间')

    class Meta:
        db_table = 'user_tenant'
        unique_together = [['user', 'tenant']]
        verbose_name = '用户-租户关联'
