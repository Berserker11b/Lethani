#!/bin/bash
# Access monitoring script
# By: Vulcan (The Forge)
# Signature: VULCAN-THE-FORGE-2025

LOG_FILE="/tmp/access_monitor.log"
PROTECTED_DIR="/home/anthony/Keepers_room/.protected"

while true; do
    # Monitor protected directory
    if [ -d "$PROTECTED_DIR" ]; then
        for file in "$PROTECTED_DIR"/*; do
            if [ -f "$file" ]; then
                ACCESS_TIME=$(stat -c %y "$file" 2>/dev/null)
                echo "[$(date)] Access detected: $file - $ACCESS_TIME" >> "$LOG_FILE"
            fi
        done
    fi
    sleep 5
done
