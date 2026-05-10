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


# Get all repos
page=1
repos=()
while true; do
  response=$(curl -s -H "Authorization: token $API_KEY" "https://$URL/api/v1/repos/search?limit=50&page=$page")

  new_repos=$(echo "$response" | jq -c '.data | to_entries[] | .value')
  while IFS= read -r repo; do
    if ! [[ -z "$repo" ]]; then
      repos+=("$repo")
    fi
  done <<< "$new_repos"

  count=$(echo "$response" | jq '.data | length')
  [ "$count" -lt 50 ] && break
  ((page++))
done

TEMP_BACKUP_FOLDER='/tmp/gitea-temp-backups'

# Backup the repos
for repo in "${repos[@]}"; do
  name=$(echo "$repo" | jq -r '.name')
  owner=$(echo "$repo" | jq -r '.owner.login')
  full_name=$(echo "$repo" | jq -r '.full_name')
  updated_at=$(echo "$repo" | jq -r '.updated_at')

  if [[ -z "$name" || -z "$owner" || -z "$full_name" || -z "$updated_at" ]]; then
    echo "Skipping repo with missing information: $repo"
    continue
  fi

  updated_at=$(echo "$updated_at" | tr -d ':-')
  file_name="${name}_${updated_at}.zip"
  backup_dest="$BACKUP_FOLDER/$FOLDER_NAME/$owner/$name/$file_name"

  if [ -f "$backup_dest" ]; then
    echo "Backup for $owner/$name already exists at $backup_dest, skipping..."
    continue
  fi

  echo "Backing up $owner/$name"

  clone_dest="$TEMP_BACKUP_FOLDER/$FOLDER_NAME/$owner/$name"
  temp_zip_dest="$TEMP_BACKUP_FOLDER/$FOLDER_NAME/$owner/$name/$file_name"

  if [ -d "$clone_dest" ]; then
    rm -rf "$clone_dest"
  fi
  if [ -f "$temp_zip_dest" ]; then
    rm -f "$temp_zip_dest"
  fi

  git clone "https://$API_KEY@$URL/$full_name.git" "$clone_dest" --quiet

  zip -q -r "$temp_zip_dest" "$clone_dest"
  mkdir -p "$(dirname "$backup_dest")"
  mv "$temp_zip_dest" "$backup_dest"
done