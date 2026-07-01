# Generated manually

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('members', '0002_member_password'),
    ]

    operations = [
        migrations.AddField(
            model_name='member',
            name='token',
            field=models.CharField(blank=True, default='', max_length=128, verbose_name='登录令牌'),
        ),
    ]
