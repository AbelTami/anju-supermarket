from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin

from .models import User, UserTenant


@admin.register(User)
class UserAdmin(BaseUserAdmin):
    list_display = ['username', 'phone', 'is_active', 'date_joined']


@admin.register(UserTenant)
class UserTenantAdmin(admin.ModelAdmin):
    list_display = ['user', 'tenant', 'role', 'joined_at']
