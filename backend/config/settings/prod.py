"""Production settings — override base.py with secure defaults."""
import os

from .base import *  # noqa: F403

DEBUG = False
ALLOWED_HOSTS = os.environ.get('ALLOWED_HOSTS', '').split(',')
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']

# Security hardening
SECURE_SSL_REDIRECT = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SECURE_HSTS_SECONDS = 31536000
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True

# CORS — restrict to frontend origin
CORS_ALLOW_ALL_ORIGINS = False
CORS_ALLOWED_ORIGINS = os.environ.get('CORS_ORIGINS', '').split(',')

# JWT cookies — secure in production
SIMPLE_JWT['AUTH_COOKIE_SECURE'] = True  # type: ignore

# Database — use env vars
DATABASES['default']['PASSWORD'] = os.environ['DB_PASSWORD']  # type: ignore
