#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# KILL UPLOAD ARTILLERY - NO SUDO VERSION
# By: Sentinel - First Circuit Guardian
# ═══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "KILL UPLOAD ARTILLERY - HEAVY HITTERS (NO SUDO)"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Find high CPU processes (user-owned only)
echo "🎯 Finding high CPU processes (user-owned)..."
HIGH_CPU=$(ps aux --sort=-%cpu | awk 'NR>1 && $3 > 50 && $1 == ENVIRON["USER"] && $11 !~ /^(ps|awk|bash|grep|sed|head|tail|sort)$/ {print $2, $3"%", $11}' | head -10)

if [ -z "$HIGH_CPU" ]; then
    echo "   ✅ No user processes using >50% CPU"
else
    echo "   ⚠️  High CPU processes found:"
    echo "$HIGH_CPU" | while read pid cpu cmd; do
        echo "      PID: $pid | CPU: $cpu | CMD: $cmd"
    done
fi
echo ""

# Find network upload processes (user-owned only)
echo "🌐 Finding network upload processes (user-owned)..."
NETWORK_PIDS=$(lsof -i -P -n 2>/dev/null | grep -E "ESTABLISHED" | awk '{print $2}' | sort -u | xargs -I {} sh -c 'ps -p {} -o user --no-headers 2>/dev/null | grep -q "^$USER$" && echo {}' 2>/dev/null)

if [ -z "$NETWORK_PIDS" ]; then
    echo "   ✅ No active network connections (user-owned)"
else
    echo "   ⚠️  Active network processes:"
    for pid in $NETWORK_PIDS; do
        PROC_INFO=$(ps -p $pid -o pid,pcpu,pmem,cmd --no-headers 2>/dev/null)
        if [ -n "$PROC_INFO" ]; then
            echo "      $PROC_INFO"
        fi
    done
fi
echo ""

# Find processes with high network I/O
echo "📡 Finding high network I/O processes..."
cat /proc/net/dev | grep -v "lo:" | awk '{if ($10 > 1000000) print $1, $10/1024/1024 " MB sent"}'
echo ""

# Kill suspicious upload processes (user-owned only)
echo "⚔️  ARTILLERY STRIKE - Killing suspicious processes (user-owned)..."
KILLED=0

# Kill processes with high CPU and network activity (user-owned only)
for pid in $NETWORK_PIDS; do
    CPU=$(ps -p $pid -o pcpu --no-headers 2>/dev/null | tr -d ' ')
    USER=$(ps -p $pid -o user --no-headers 2>/dev/null)
    if [ "$USER" = "$(whoami)" ] && [ -n "$CPU" ] && (( $(echo "$CPU > 20" | bc -l 2>/dev/null || echo 0) )); then
        CMD=$(ps -p $pid -o cmd --no-headers 2>/dev/null | head -c 60)
        echo "   🎯 Targeting PID $pid (CPU: ${CPU}%) - $CMD"
        
        # Check if it's a system process we shouldn't kill
        if [[ "$CMD" != *"cursor"* ]] && [[ "$CMD" != *"systemd"* ]] && [[ "$CMD" != *"kernel"* ]]; then
            kill -9 $pid 2>/dev/null && echo "      ✅ KILLED" && KILLED=$((KILLED + 1)) || echo "      ⚠️  Failed to kill"
        else
            echo "      ⏸️  Skipping system process"
        fi
    fi
done

# Kill processes matching upload patterns (user-owned only)
UPLOAD_PIDS=$(ps aux | grep "^$(whoami)" | grep -E "upload|sync|backup|transfer|wget|curl|rsync|scp|ftp" | grep -v grep | awk '{print $2}')

if [ -n "$UPLOAD_PIDS" ]; then
    echo ""
    echo "   🎯 Targeting upload-related processes..."
    for pid in $UPLOAD_PIDS; do
        CMD=$(ps -p $pid -o cmd --no-headers 2>/dev/null | head -c 60)
        echo "      PID $pid - $CMD"
        kill -9 $pid 2>/dev/null && echo "         ✅ KILLED" && KILLED=$((KILLED + 1)) || echo "         ⚠️  Failed to kill"
    done
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "⚔️  ARTILLERY STRIKE COMPLETE"
echo "   Killed: $KILLED processes"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Run bloodhound tracer to find commander
echo "🐺 Running BLOODHOUND TRACER to find commander..."
cd /home/anthony/Keepers_room
python3 BLOODHOUND_TRACER.py 2>/dev/null | tail -20

echo ""
echo "🛡️  Sentinel - Artillery strike complete"
echo "══════════════════════════════════════════════════════════════"









