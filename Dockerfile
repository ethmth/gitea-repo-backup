FROM python:3.12-slim

WORKDIR /app

ENV PYTHONUNBUFFERED=1

RUN apt-get update \
    && apt-get install -y cron yq jq \
    && python3 -m pip install --no-cache-dir pyyaml \
    && rm -rf /var/lib/apt/lists/*

COPY src /app/src

RUN chmod +x /app/src/*.sh /app/src/*.py

ENTRYPOINT ["/app/src/start.sh"]
