#!/usr/bin/env bash

# Defaults
URL=''
API_KEY='${GITEA_API_KEY}'
FOLDER_NAME='gitea'
BACKUP_FOLDER='backups'
ENV_FILE='.env'

usage() {
  echo "Usage: $0 --url <url> [--api-key <key>] [--folder-name <name>]"
  echo
  echo "  --url          (required) Target URL"
  echo "  --api-key      (optional) API key string TO EVALUATE, so if you pass in the string '${GITEA_API_KEY}', it will be evaluated in this script (default: '${GITEA_API_KEY}')"
  echo "  --folder-name  (optional) Folder name (default: $FOLDER_NAME)"
  echo "  --backup-folder (optional) Root Backup folder (default: ./backups)"
  echo "  --env-file (optional) Path to .env file to load environment variables from (default: ./.env)"
  exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --url)         URL="$2";         shift 2 ;;
    --api-key)     API_KEY="$2";     shift 2 ;;
    --folder-name) FOLDER_NAME="$2"; shift 2 ;;
    --backup-folder) BACKUP_FOLDER="$2"; shift 2 ;;
    --env-file) ENV_FILE="$2"; shift 2 ;;
    *) echo "Unknown argument: $1"; usage ;;
  esac
done

# Load environment variables from the specified file
if [[ -f "$ENV_FILE" ]]; then
  export $(cat "$ENV_FILE" | xargs)
fi

# Evaluate variables
URL=$(eval "echo $URL")
API_KEY=$(eval "echo $API_KEY")
FOLDER_NAME=$(eval "echo $FOLDER_NAME")
BACKUP_FOLDER=$(eval "echo $BACKUP_FOLDER")

# Validate required arguments
if [[ -z "$URL" ]]; then
  echo "Error: --url is required"
  usage
fi

echo "URL:         $URL"
echo "API Key:     $API_KEY"
echo "Folder Name: $FOLDER_NAME"
echo "Backup Folder: $BACKUP_FOLDER"