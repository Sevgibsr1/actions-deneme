import pytest
from redis.exceptions import ConnectionError

from web import app as app_module


class DummyRedis:
    def __init__(self) -> None:
        self.store = {}
        self.ping_calls = 0

    def ping(self) -> bool:
        self.ping_calls += 1
        return True

    def incr(self, key: str) -> int:
        self.store[key] = self.store.get(key, 0) + 1
        return self.store[key]


class FailingRedis:
    def __init__(self, max_attempts: int = 3) -> None:
        self.attempts = 0
        self.max_attempts = max_attempts

    def ping(self) -> bool:
        raise ConnectionError("redis is unavailable")

    def incr(self, key: str) -> int:
        self.attempts += 1
        raise ConnectionError("redis is unavailable")


@pytest.fixture()
def client():
    return app_module.app.test_client()


def test_health_reports_up_when_redis_ping_succeeds(monkeypatch, client):
    dummy = DummyRedis()
    monkeypatch.setattr(app_module, "redis_client", dummy)

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"app": "up", "redis": "up"}
    assert dummy.ping_calls == 1


def test_health_reports_down_when_redis_unavailable(monkeypatch, client):
    failing = FailingRedis()
    monkeypatch.setattr(app_module, "redis_client", failing)

    response = client.get("/health")

    assert response.status_code == 200
    assert response.json == {"app": "up", "redis": "down"}


def test_counter_increments_value(monkeypatch, client):
    dummy = DummyRedis()
    monkeypatch.setattr(app_module, "redis_client", dummy)

    first = client.get("/counter")
    second = client.get("/counter")

    assert first.status_code == 200
    assert second.status_code == 200
    assert first.json["counter"] == 1
    assert second.json["counter"] == 2


def test_counter_returns_service_unavailable_when_redis_down(monkeypatch, client):
    failing = FailingRedis()
    monkeypatch.setattr(app_module, "redis_client", failing)

    response = client.get("/counter")

    assert response.status_code == 503
    assert response.json == {"error": "cannot connect to redis"}

