#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# CPU COMPRESSOR - THROTTLE HIGH CPU PROCESSES
# Compresses CPU usage of attacking processes
# ═══════════════════════════════════════════════════════════════

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RECORD_DIR="/home/anthony/Keepers_room/evidence/compressor_${TIMESTAMP}"
mkdir -p "$RECORD_DIR"/{processes,compressed}

echo "⚙️  CPU COMPRESSOR ACTIVATED"
echo "Compressing high CPU processes..."
echo "═══════════════════════════════════════════════════════════════"
echo ""

# ═══════════════════════════════════════════════════════════════
# 1. IDENTIFY HIGH CPU PROCESSES
# ═══════════════════════════════════════════════════════════════
echo "[1] Identifying high CPU processes..."

ps aux --sort=-%cpu > "$RECORD_DIR/processes/before_compression.txt"

# Get processes >30% CPU (excluding system processes and Cursor)
HIGH_CPU=$(ps aux --sort=-%cpu | awk 'NR>1 && $3>30 && $11!~/^\[/ && $11!~/systemd|kernel|init|Xorg|cursor/ && $0!~/\/usr\/share\/cursor/ {print $2":"$3":"$11":"$1}' | head -10)

if [ -z "$HIGH_CPU" ]; then
    echo "  No high CPU processes found"
    exit 0
fi

echo "High CPU processes to compress:"
echo "$HIGH_CPU" | while IFS=: read pid cpu name user; do
    if [ -n "$pid" ]; then
        echo "  PID $pid: ${cpu}% CPU - $name (user: $user)"
        echo "PID $pid: ${cpu}% CPU - $name (user: $user)" >> "$RECORD_DIR/processes/targets.txt"
    fi
done

# ═══════════════════════════════════════════════════════════════
# 2. APPLY CPU COMPRESSION (NICE + CPULIMIT)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "[2] Applying CPU compression..."

COMPRESSED=0
echo "$HIGH_CPU" | while IFS=: read pid cpu name user; do
    if [ -n "$pid" ] && [ "$pid" != "" ]; then
        # NEVER COMPRESS CURSOR OR ESSENTIAL PROCESSES
        PROC_CMD=$(ps -p "$pid" -o cmd= 2>/dev/null || echo "")
        if echo "$PROC_CMD" | grep -qiE "(cursor|/usr/share/cursor|bash|sh|python3|continuous_puppy|thermal_guardian)"; then
            echo "  ⚠️  SKIPPING: PID $pid is Cursor or essential process - NOT COMPRESSING"
            continue
        fi
        
        # Skip if it's our own script
        if echo "$PROC_CMD" | grep -qiE "(ELIMINATE|TARGET|RAPID_RESPONSE|CPU_COMPRESSOR)"; then
            echo "  ⚠️  SKIPPING: PID $pid is our own script - NOT COMPRESSING"
            continue
        fi
        
        # Skip if already low priority
        CURRENT_NICE=$(ps -p "$pid" -o ni= 2>/dev/null | tr -d ' ' || echo "0")
        
        echo "  Compressing PID $pid ($name) - ${cpu}% CPU..."
        
        # Method 1: Renice to low priority
        renice +19 -p "$pid" 2>/dev/null && {
            echo "    ✅ Reniced PID $pid to low priority"
            echo "PID $pid: Reniced to +19 (low priority)" >> "$RECORD_DIR/compressed/compressed.txt"
        } || {
            echo "    ⚠️  Cannot renice PID $pid (may need sudo)"
            echo "PID $pid: Renice failed" >> "$RECORD_DIR/compressed/failed.txt"
        }
        
        # Method 2: Use cpulimit if available
        if command -v cpulimit >/dev/null 2>&1; then
            # Limit to 20% CPU
            cpulimit -p "$pid" -l 20 -b 2>/dev/null && {
                echo "    ✅ Limited PID $pid to 20% CPU"
                echo "PID $pid: Limited to 20% CPU" >> "$RECORD_DIR/compressed/compressed.txt"
            } || true
        fi
        
        # Method 3: Use ionice for I/O priority
        ionice -c 3 -p "$pid" 2>/dev/null && {
            echo "    ✅ Set I/O priority to idle for PID $pid"
            echo "PID $pid: I/O priority set to idle" >> "$RECORD_DIR/compressed/compressed.txt"
        } || true
        
        COMPRESSED=$((COMPRESSED + 1))
    fi
done

# ═══════════════════════════════════════════════════════════════
# 3. APPLY SYSTEM-WIDE CPU LIMITS (if possible)
# ═══════════════════════════════════════════════════════════════
echo ""
echo "[3] Applying system-wide compression..."

# Check if we can use cgroups
if [ -d /sys/fs/cgroup/cpu ] && [ "$EUID" -eq 0 ]; then
    echo "  Using cgroups to limit CPU..."
    # Create cgroup for compression
    mkdir -p /sys/fs/cgroup/cpu/compressed 2>/dev/null || true
    echo "100000" > /sys/fs/cgroup/cpu/compressed/cpu.cfs_quota_us 2>/dev/null || true
    echo "1000000" > /sys/fs/cgroup/cpu/compressed/cpu.cfs_period_us 2>/dev/null || true
    
    # Move processes to compressed cgroup
    echo "$HIGH_CPU" | while IFS=: read pid cpu name user; do
        if [ -n "$pid" ]; then
            echo "$pid" > /sys/fs/cgroup/cpu/compressed/cgroup.procs 2>/dev/null || true
        fi
    done
    echo "  ✅ Cgroup compression applied"
elif [ "$EUID" -ne 0 ]; then
    echo "  ⚠️  Cgroup compression requires sudo"
fi

# ═══════════════════════════════════════════════════════════════
# 4. VERIFY COMPRESSION
# ═══════════════════════════════════════════════════════════════
echo ""
echo "[4] Verifying compression..."

sleep 3
ps aux --sort=-%cpu > "$RECORD_DIR/processes/after_compression.txt"

echo "CPU usage after compression:"
ps aux --sort=-%cpu | head -10 | awk 'NR>1 {printf "  PID %s: %.1f%% CPU - %s\n", $2, $3, $11}'

# ═══════════════════════════════════════════════════════════════
# 5. CREATE COMPRESSION REPORT
# ═══════════════════════════════════════════════════════════════
cat > "$RECORD_DIR/COMPRESSION_REPORT.txt" << EOF
CPU COMPRESSION REPORT
═══════════════════════════════════════════════════════════════

Time: $(date)
Action: CPU Compression Applied
Target: High CPU Processes

═══════════════════════════════════════════════════════════════
PROCESSES COMPRESSED
═══════════════════════════════════════════════════════════════
EOF

if [ -f "$RECORD_DIR/compressed/compressed.txt" ]; then
    cat "$RECORD_DIR/compressed/compressed.txt" >> "$RECORD_DIR/COMPRESSION_REPORT.txt"
else
    echo "None compressed" >> "$RECORD_DIR/COMPRESSION_REPORT.txt"
fi

cat >> "$RECORD_DIR/COMPRESSION_REPORT.txt" << EOF

═══════════════════════════════════════════════════════════════
COMPRESSION METHODS APPLIED
═══════════════════════════════════════════════════════════════

1. Renice to low priority (+19)
2. CPU limit (if cpulimit available)
3. I/O priority to idle
4. Cgroup limits (if root)

═══════════════════════════════════════════════════════════════
EVIDENCE LOCATION
═══════════════════════════════════════════════════════════════

All evidence recorded in: $RECORD_DIR

Files:
- processes/ - Process information
- compressed/ - Compression logs
- COMPRESSION_REPORT.txt - This report

═══════════════════════════════════════════════════════════════
EOF

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ CPU COMPRESSION COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Processes Compressed: $COMPRESSED"
echo "Evidence: $RECORD_DIR"
echo ""
echo "Review report:"
echo "  cat $RECORD_DIR/COMPRESSION_REPORT.txt"
echo ""
echo "CPU usage should be reduced now."
echo ""

