#!/bin/sh
set -e

CONFIG_FILE="/app/config.yml"
CRON_FILE="/etc/cron.d/gitea-backup"

/app/src/generate-cron.sh "$CONFIG_FILE" > "$CRON_FILE"
chmod 0644 "$CRON_FILE"

# Start cron in the foreground.
exec cron -f
