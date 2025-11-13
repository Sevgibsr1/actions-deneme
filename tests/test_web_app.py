import importlib

import fakeredis
import pytest


@pytest.fixture()
def app_client(monkeypatch):
    monkeypatch.setenv("COUNTER_KEY", "test-counter")
    module = importlib.import_module("web.app")

    fake_redis = fakeredis.FakeRedis()
    monkeypatch.setattr(module, "redis_client", fake_redis, raising=False)

    module.app.config.update(TESTING=True)
    client = module.app.test_client()
    yield client, fake_redis
    fake_redis.flushall()


def test_health_endpoint_reports_redis_up(app_client):
    client, _ = app_client
    response = client.get("/health")
    payload = response.get_json()

    assert response.status_code == 200
    assert payload["app"] == "up"
    assert payload["redis"] == "up"


def test_counter_endpoint_increments(app_client):
    client, fake_redis = app_client

    first = client.get("/counter")
    second = client.get("/counter")

    assert first.status_code == 200
    assert second.status_code == 200
    assert first.get_json()["counter"] == 1
    assert second.get_json()["counter"] == 2

    # Doğrudan Redis içeriğini de doğrula
    assert int(fake_redis.get("test-counter")) == 2
