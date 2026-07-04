from django.apps import AppConfig


class PosConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.pos'

    def ready(self):
        import apps.pos.signals  # noqa: F401 — register signal handlers
