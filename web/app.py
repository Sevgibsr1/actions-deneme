import os
import time
from typing import Optional

from flask import Flask, jsonify
import redis


def create_redis_client() -> redis.Redis:
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


app = Flask(__name__)
_redis: Optional[redis.Redis] = None


def get_redis() -> redis.Redis:
	global _redis
	if _redis is None:
		_redis = create_redis_client()
	return _redis


@app.get("/")
def root():
	return "OK", 200


@app.get("/counter")
def counter():
	client = get_redis()
	# Basic retry for initial startup race with Redis
	for attempt in range(3):
		try:
			value = client.incr("counter")
			return jsonify({"counter": int(value)})
		except redis.exceptions.ConnectionError:
			time.sleep(0.5 * (attempt + 1))
	return jsonify({"error": "cannot connect to redis"}), 503


if __name__ == "__main__":
	host = os.getenv("FLASK_RUN_HOST", "0.0.0.0")
	port = int(os.getenv("FLASK_RUN_PORT", "5000"))
	app.run(host=host, port=port)

import os
import time
from typing import Optional

from flask import Flask, jsonify
import redis


def create_redis_client() -> redis.Redis:
    redis_host = os.getenv("REDIS_HOST", "redis")
    redis_port = int(os.getenv("REDIS_PORT", "6379"))
    return redis.Redis(host=redis_host, port=redis_port, db=0, socket_timeout=2.0)


def wait_for_redis(client: redis.Redis, max_wait_seconds: int = 20) -> None:
    deadline = time.time() + max_wait_seconds
    last_error: Optional[Exception] = None
    while time.time() < deadline:
        try:
            if client.ping():
                return
        except Exception as exc:  # pragma: no cover
            last_error = exc
            time.sleep(0.5)
    if last_error:
        raise last_error
    raise TimeoutError("Redis startup wait timed out")


app = Flask(__name__)
redis_client = create_redis_client()

try:
    wait_for_redis(redis_client)
except Exception:
    # Uygulama yine de ayağa kalksın, health endpoint'i durum versin
    pass


@app.get("/")
def root():
    return jsonify(status="OK")


@app.get("/health")
def health():
    try:
        redis_client.ping()
        redis_status = "up"
    except Exception:  # pragma: no cover
        redis_status = "down"
    return jsonify(app="up", redis=redis_status)


@app.get("/counter")
def counter():
    key = os.getenv("COUNTER_KEY", "visits")
    value = redis_client.incr(key)
    return jsonify(counter=value)


