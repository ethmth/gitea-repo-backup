FROM debian:trixie-slim

WORKDIR /app

RUN apt-get update \
    && apt-get install -y cron yq jq curl git zip \
    && rm -rf /var/lib/apt/lists/*

COPY src /app/src

RUN chmod +x /app/src/*.sh

ENTRYPOINT ["/app/src/docker-entrypoint.sh"]
