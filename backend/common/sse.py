"""In-process pub/sub event bus for SSE (Server-Sent Events).

Uses threading.Queue for compatibility with Django's sync/threaded runserver.
"""
import json
import queue
import threading
from collections import defaultdict

# {tenant_id: [queue.Queue, ...]}
_subscribers: dict[int, list[queue.Queue]] = defaultdict(list)
_lock = threading.Lock()


def subscribe(tenant_id: int) -> queue.Queue:
    """Create a new subscriber queue for a tenant."""
    q: queue.Queue = queue.Queue(maxsize=50)
    with _lock:
        _subscribers[tenant_id].append(q)
    return q


def unsubscribe(tenant_id: int, q: queue.Queue) -> None:
    """Remove a subscriber queue."""
    with _lock:
        try:
            _subscribers[tenant_id].remove(q)
        except ValueError:
            pass


def publish(tenant_id: int, event_type: str, data: dict) -> None:
    """Publish an event to all subscribers of a tenant."""
    with _lock:
        queues = list(_subscribers.get(tenant_id, []))
    if not queues:
        return
    payload = json.dumps({"type": event_type, "data": data}, ensure_ascii=False)
    for q in queues:
        try:
            q.put_nowait(payload)
        except queue.Full:
            with _lock:
                try:
                    _subscribers[tenant_id].remove(q)
                except ValueError:
                    pass
