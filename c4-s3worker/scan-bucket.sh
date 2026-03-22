#!/bin/bash
set -euo pipefail

# S3 bucket scanner — downloads objects, computes C4 IDs, produces c4m.
#
# Downloads each object to a temp directory (preserving key structure),
# then runs c4 to scan the tree and produce a manifest.
#
# Environment:
#   S3_BUCKET              — bucket to scan (required)
#   S3_PREFIX              — key prefix to filter (optional, default: "")
#   S3_ENDPOINT            — custom S3 endpoint for non-AWS providers (optional)
#   S3_REGION              — AWS region (default: us-east-1)
#   AWS_ACCESS_KEY_ID      — credentials (required)
#   AWS_SECRET_ACCESS_KEY  — credentials (required)
#   OUTPUT_PATH            — where to write the c4m (default: /output/manifest.c4m)
#   C4_STORE               — content store path (optional, enables storage)
#   MAX_OBJECT_SIZE        — skip objects larger than this (default: no limit)

: "${S3_BUCKET:?S3_BUCKET is required}"
: "${S3_REGION:=us-east-1}"
: "${S3_PREFIX:=}"
: "${OUTPUT_PATH:=/output/manifest.c4m}"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

# Build AWS CLI flags
AWS_FLAGS="--region $S3_REGION"
if [ -n "${S3_ENDPOINT:-}" ]; then
    AWS_FLAGS="$AWS_FLAGS --endpoint-url $S3_ENDPOINT"
fi

echo "Scanning s3://${S3_BUCKET}/${S3_PREFIX}" >&2

# Sync bucket contents to temp directory (preserving key structure)
S3_PATH="s3://${S3_BUCKET}"
if [ -n "$S3_PREFIX" ]; then
    S3_PATH="${S3_PATH}/${S3_PREFIX}"
fi

echo "Downloading objects to staging directory..." >&2
aws s3 sync $AWS_FLAGS "$S3_PATH" "$WORKDIR/" --no-progress 2>&1 | \
    while IFS= read -r line; do echo "  $line" >&2; done

# Count downloaded objects
OBJECT_COUNT=$(find "$WORKDIR" -type f | wc -l | tr -d ' ')
echo "Downloaded $OBJECT_COUNT objects" >&2

if [ "$OBJECT_COUNT" -eq 0 ]; then
    echo "Warning: no objects found at s3://${S3_BUCKET}/${S3_PREFIX}" >&2
    # Write empty manifest
    mkdir -p "$(dirname "$OUTPUT_PATH")"
    touch "$OUTPUT_PATH"
    exit 0
fi

# Ensure output directory exists
mkdir -p "$(dirname "$OUTPUT_PATH")"

# Scan with c4 — produces c4m manifest, optionally stores content
echo "Computing C4 IDs..." >&2
if [ -n "${C4_STORE:-}" ]; then
    c4 patch -s "$WORKDIR" "$OUTPUT_PATH"
else
    c4 patch "$WORKDIR" "$OUTPUT_PATH"
fi

# Report
ENTRY_COUNT=$(wc -l < "$OUTPUT_PATH" | tr -d ' ')
echo "Manifest written to $OUTPUT_PATH ($ENTRY_COUNT entries)" >&2
echo "Done." >&2
