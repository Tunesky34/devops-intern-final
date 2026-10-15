#!/usr/bin/env sh

set -eu

url="${1:-http://localhost:8080/health}"

if command -v curl >/dev/null 2>&1; then
    curl --fail --silent --show-error "$url" >/dev/null
elif command -v wget >/dev/null 2>&1; then
    wget --quiet --output-document=/dev/null "$url"
else
    printf 'Error: healthcheck requires curl or wget.\n' >&2
    exit 127
fi

printf 'Health check passed: %s\n' "$url"
