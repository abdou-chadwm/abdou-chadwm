#!/bin/sh

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Please run as root (use sudo)."
    exit 1
fi

echo "--- Starting Void Linux Cleanup ---"

# 1. Remove orphaned dependencies and obsolete package cache
# -O: Remove obsolete packages from cache
# -o: Remove orphaned dependencies
echo "[1/3] Removing orphans and cleaning obsolete cache..."
xbps-remove -Ooo

# 2. Purge old kernels
# This keeps only the currently running kernel.
echo "[2/3] Purging old kernels..."
if command -v vkpurge >/dev/null 2>&1; then
    vkpurge rm all
else
    echo "vkpurge not found, skipping kernel cleanup."
fi

# 3. Optional: Clear entire cache if requested
# I've left this commented out by default for safety.
# echo "[3/3] Clearing entire package cache..."
# xbps-remove -OO -y

echo "--- Cleanup Complete! ---"
