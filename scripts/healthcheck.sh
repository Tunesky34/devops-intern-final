#!/usr/bin/env sh

set -eu

url="${1:-http://localhost:8080}"

if ! command -v curl >/dev/null 2>&1; then
    printf 'Error: healthcheck requires curl.\n' >&2
    exit 127
fi

if ! http_status=$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' "$url"); then
    printf 'Health check failed: request to %s did not complete.\n' "$url" >&2
    exit 1
fi

if [ "$http_status" != "200" ]; then
    printf 'Health check failed: %s returned HTTP %s (expected 200).\n' "$url" "$http_status" >&2
    exit 1
fi

printf 'Health check passed: %s returned HTTP 200.\n' "$url"
