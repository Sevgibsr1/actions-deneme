#!/usr/bin/env python3
"""
Flask web uygulaması - Redis ile sayaç servisi
"""

import os
import time
from typing import Optional

from flask import Flask, jsonify
import redis


def create_redis_client() -> redis.Redis:
    """Redis client oluşturur ve yapılandırır."""
    redis_host = os.getenv("REDIS_HOST", "redis")
    redis_port = int(os.getenv("REDIS_PORT", "6379"))
    redis_db = int(os.getenv("REDIS_DB", "0"))
    redis_password: Optional[str] = os.getenv("REDIS_PASSWORD") or None

    return redis.Redis(
        host=redis_host,
        port=redis_port,
        db=redis_db,
        password=redis_password,
        socket_timeout=2,
        socket_connect_timeout=2,
        health_check_interval=30,
    )


def wait_for_redis(client: redis.Redis, max_wait_seconds: int = 20) -> None:
    """Redis'in hazır olmasını bekler."""
    deadline = time.time() + max_wait_seconds
    last_error: Optional[Exception] = None
    while time.time() < deadline:
        try:
            if client.ping():
                return
        except Exception as exc:
            last_error = exc
            time.sleep(0.5)
    if last_error:
        raise last_error
    raise TimeoutError("Redis startup wait timed out")


# Flask uygulaması
app = Flask(__name__)
redis_client = create_redis_client()

# Uygulama başlarken Redis'e bağlanmayı dene
try:
    wait_for_redis(redis_client)
except Exception:
    # Uygulama yine de ayağa kalksın, health endpoint'i durum versin
    pass


@app.get("/")
def root():
    """Ana endpoint - uygulama durumunu döner."""
    return jsonify(status="OK")


@app.get("/health")
def health():
    """Health check endpoint - uygulama ve Redis durumunu kontrol eder."""
    try:
        redis_client.ping()
        redis_status = "up"
    except Exception:
        redis_status = "down"
    return jsonify(app="up", redis=redis_status)


@app.get("/counter")
def counter():
    """Sayaç endpoint'i - Redis'teki sayacı artırır ve döner."""
    key = os.getenv("COUNTER_KEY", "visits")
    # Basic retry for initial startup race with Redis
    for attempt in range(3):
        try:
            value = redis_client.incr(key)
            return jsonify(counter=int(value))
        except redis.exceptions.ConnectionError:
            time.sleep(0.5 * (attempt + 1))
    return jsonify(error="cannot connect to redis"), 503


if __name__ == "__main__":
    host = os.getenv("FLASK_RUN_HOST", "0.0.0.0")
    port = int(os.getenv("FLASK_RUN_PORT", "5000"))
    app.run(host=host, port=port)
