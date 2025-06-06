#!/bin/bash

set -euxo pipefail

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <existing_bucket> <new_bucket> <endpoint_url>"
    exit 1
fi

EXISTING_BUCKET_NAME="$1"
NEW_BACKUP_BUCKET="$2"
ENDPOINT_URL="$3"

create_bucket() {
    local bucket="$1"
    echo "Creating new bucket: $bucket"
    aws --endpoint-url "$ENDPOINT_URL" s3api create-bucket --bucket "$bucket" --region RegionOne || echo "Bucket $bucket already exists or creation failed"
}

clone_bucket_data() {
    local source_bucket="$1"
    local dest_bucket="$2"
    echo "Running aws s3 sync from $source_bucket to $dest_bucket"
    aws --endpoint-url "$ENDPOINT_URL" s3 sync "s3://$source_bucket" "s3://$dest_bucket" --exact-timestamps --delete
}

create_bucket "$NEW_BACKUP_BUCKET"
clone_bucket_data "$EXISTING_BUCKET_NAME" "$NEW_BACKUP_BUCKET"

echo "Backup completed"