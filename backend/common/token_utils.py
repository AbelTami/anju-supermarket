"""Token hashing utilities — HMAC-SHA256 over the raw token.

Why HMAC over plain sha256: the HMAC key (settings.SECRET_KEY) makes precomputed
rainbow tables useless. Two tenants with the same raw token still hash to the
same value, but the attacker would need SECRET_KEY to even attempt an offline
dictionary — and if they have SECRET_KEY, the system is already compromised.
"""
import hashlib
import hmac

from django.conf import settings


def hash_token(token: str) -> str:
    """Return HMAC-SHA256 hex digest of a raw token, keyed by SECRET_KEY."""
    return hmac.new(
        settings.SECRET_KEY.encode(),
        token.encode(),
        hashlib.sha256,
    ).hexdigest()


def get_member_from_request(request):
    """Extract and return a Member from the Authorization: Token header, or None.

    Looks up the token hash against the Member table scoped to request.tenant.
    """
    from apps.members.models import Member

    auth = request.headers.get('Authorization', '')
    if not auth.startswith('Token '):
        return None
    token_hash = hash_token(auth[6:])
    try:
        return Member.objects.get(token=token_hash, tenant=request.tenant)
    except Member.DoesNotExist:
        return None
