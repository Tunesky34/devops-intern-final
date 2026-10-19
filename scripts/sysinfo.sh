#!/usr/bin/env sh

set -eu

print_section() {
    printf '\n== %s ==\n' "$1"
}

print_section "System"
printf 'Current user: %s\n' "$(id -un)"
printf 'Effective UID: %s\n' "$(id -u)"
printf 'Hostname: %s\n' "$(hostname)"
printf 'Kernel: %s\n' "$(uname -sr)"
printf 'Architecture: %s\n' "$(uname -m)"
printf 'System date (ISO-8601): %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')"

print_section "Docker"
if command -v docker >/dev/null 2>&1; then
    if docker info >/dev/null 2>&1; then
        printf 'Docker daemon: running\n'
    else
        printf 'Docker daemon: unavailable\n'
    fi
else
    printf 'Docker CLI: not installed\n'
fi

print_section "Memory"
if command -v free >/dev/null 2>&1; then
    free -h
elif [ -r /proc/meminfo ]; then
    awk '/^(MemTotal|MemAvailable):/ { print }' /proc/meminfo
else
    printf 'Memory information is unavailable.\n'
fi

print_section "Disk"
df -h .
