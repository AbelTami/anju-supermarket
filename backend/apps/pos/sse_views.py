"""SSE (Server-Sent Events) view for real-time order push."""
import queue
import time

from common.sse import subscribe, unsubscribe
from django.http import Http404, HttpResponse, StreamingHttpResponse
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework_simplejwt.exceptions import InvalidToken

from apps.tenants.models import Tenant


def order_sse_view(request, tenant_slug):
    """GET /api/{tenant_slug}/orders/stream/?token=xxx — SSE stream of new orders.

    JWT auth via Authorization header or ?token= query param (for EventSource).
    """
    # Authenticate
    token = request.GET.get('token', '')
    if token and not request.META.get('HTTP_AUTHORIZATION'):
        request.META['HTTP_AUTHORIZATION'] = f'Bearer {token}'

    jwt_auth = JWTAuthentication()
    try:
        auth_result = jwt_auth.authenticate(request)
        if auth_result is None:
            raise InvalidToken()
        request.user = auth_result[0]
    except InvalidToken:
        return HttpResponse(
            '{"error": "unauthorized"}',
            content_type="application/json",
            status=401,
        )

    # Resolve tenant
    try:
        tenant = Tenant.objects.get(slug=tenant_slug, is_active=True)
    except Tenant.DoesNotExist:
        raise Http404("Tenant not found")
    request.tenant = tenant

    q = subscribe(tenant.id)

    def event_stream():
        try:
            yield "event: connected\ndata: {}\n\n"
            while True:
                try:
                    payload = q.get(timeout=30)
                    yield f"data: {payload}\n\n"
                except queue.Empty:
                    yield ": ping\n\n"
        except GeneratorExit:
            pass
        finally:
            unsubscribe(tenant.id, q)

    response = StreamingHttpResponse(
        event_stream(),
        content_type="text/event-stream",
        status=200,
    )
    response["Cache-Control"] = "no-cache"
    response["X-Accel-Buffering"] = "no"
    return response
