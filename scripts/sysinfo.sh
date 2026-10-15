#!/usr/bin/env sh

set -eu

print_section() {
    printf '\n== %s ==\n' "$1"
}

print_section "System"
printf 'Hostname: %s\n' "$(hostname)"
printf 'Kernel: %s\n' "$(uname -sr)"
printf 'Architecture: %s\n' "$(uname -m)"

print_section "Uptime"
if [ -r /proc/uptime ]; then
    awk '{ printf "Uptime: %.0f seconds\n", $1 }' /proc/uptime
elif command -v uptime >/dev/null 2>&1; then
    uptime
else
    printf 'Uptime information is unavailable.\n'
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
