#!/usr/bin/env bash

CONFIG_FILE="$1"

if [ -z "$CONFIG_FILE" ]; then
    echo "Usage: $0 <config_file>"
    exit 1
fi

entries=$(cat "$CONFIG_FILE" | yq -c '.gitea | to_entries[] | .value')
while IFS= read -r entry; do
    url=$(echo "$entry" | jq -r '.["url"]')
    schedule=$(echo "$entry" | jq -r '.["schedule"]')
    api_key=$(echo "$entry" | jq -r '.["api-key"]')
    folder_name=$(echo "$entry" | jq -r '.["folder-name"]')
    echo "$schedule $(whoami) /app/src/start.sh --url '$url' --api-key '$api_key' --folder-name '$folder_name' >> /var/log/cron.log 2>&1"
done <<< "$entries"