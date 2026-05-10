#!/usr/bin/env bash

# Defaults
API_KEY='${GITEA_API_KEY}'
FOLDER_NAME='gitea'

usage() {
  echo "Usage: $0 --url <url> [--api-key <key>] [--folder-name <name>]"
  echo
  echo "  --url          (required) Target URL"
  echo "  --api-key      (optional) API key string TO EVALUATE, so if you pass in the string '${GITEA_API_KEY}', it will be evaluated in this script (default: '${GITEA_API_KEY}')"
  echo "  --folder-name  (optional) Folder name (default: $FOLDER_NAME)"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --url)         URL="$2";         shift 2 ;;
    --api-key)     API_KEY="$2";     shift 2 ;;
    --folder-name) FOLDER_NAME="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

# Validate required arguments
if [[ -z "$URL" ]]; then
  echo "Error: --url is required"
  usage
fi

echo "URL:         $URL"
echo "API Key:     $API_KEY"
echo "Folder Name: $FOLDER_NAME"