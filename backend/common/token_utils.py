"""Token hashing utilities — SHA-256 one-way hash for member auth tokens."""
import hashlib


def hash_token(token: str) -> str:
    """Return SHA-256 hex digest of a raw token."""
    return hashlib.sha256(token.encode()).hexdigest()


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
