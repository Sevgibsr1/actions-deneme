FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
	PYTHONUNBUFFERED=1 \
	FLASK_APP=app.py \
	FLASK_RUN_HOST=0.0.0.0 \
	FLASK_RUN_PORT=5000

WORKDIR /app

# Install runtime dependencies (if any are needed later)
RUN apt-get update && apt-get install -y --no-install-recommends \
		# keep minimal; placeholder for future OS deps
	&& rm -rf /var/lib/apt/lists/*

COPY web/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

COPY web /app

# Create and use non-root user
RUN useradd --create-home --home-dir /home/appuser --shell /bin/bash appuser \
	&& chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]

