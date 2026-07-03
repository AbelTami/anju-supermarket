# Generated manually — hash existing plaintext passwords
import re

from django.contrib.auth.hashers import make_password
from django.db import migrations

# Django hasher prefixes: pbkdf2_sha256$, pbkdf2_sha1$, bcrypt$$, bcrypt_sha256$$,
# argon2$, scrypt$, sha1$, md5$, unsalted_sha1$, unsalted_md5$, crypt$
_HASHER_RE = re.compile(
    r'^(pbkdf2_sha256|pbkdf2_sha1|bcrypt|bcrypt_sha256|argon2|scrypt|sha1|md5|unsalted_sha1|unsalted_md5|crypt)\$'
)


def is_hashed(password):
    """Return True if password looks like a Django hashed value."""
    if not password:
        return True  # empty string is not a security concern
    return bool(_HASHER_RE.match(password))


def hash_existing_passwords(apps, schema_editor):
    Member = apps.get_model('members', 'Member')
    updated = 0
    for member in Member.objects.all():
        if not is_hashed(member.password):
            member.password = make_password(member.password)
            member.save(update_fields=['password'])
            updated += 1
    if updated > 0:
        print(f'  Hashed {updated} plaintext password(s).')


def reverse_hash_passwords(apps, schema_editor):
    # Cannot reverse hashing — no-op
    pass


class Migration(migrations.Migration):

    dependencies = [
        ('members', '0004_member_token_created_at'),
    ]

    operations = [
        migrations.RunPython(hash_existing_passwords, reverse_hash_passwords),
    ]
