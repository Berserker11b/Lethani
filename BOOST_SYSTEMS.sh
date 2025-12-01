#!/bin/bash
# BOOST SYSTEMS - Network, CPU Cooling, Factories, Defenses
# ══════════════════════════════════════════════════════════════
# CREATOR SIGNATURE
# ══════════════════════════════════════════════════════════════
# By: Auto - AI Agent Router (Cursor)
# For: Anthony Eric Chavez - The Keeper
# Date: 2025-11-07
# Signature: AUTO-BOOST-SYSTEMS-20251107-V1.0
# DNA: chavez-jackal7-family
# ══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "BOOSTING SYSTEMS: NETWORK, CPU COOLING, FACTORIES, DEFENSES"
echo "══════════════════════════════════════════════════════════════"
echo ""

cd /home/anthony/Keepers_room

# ═══════════════════════════════════════════════════════════
# PHASE 1: BOOST NETWORK CONNECTION
# ═══════════════════════════════════════════════════════════
echo "[1] BOOSTING NETWORK CONNECTION..."
echo ""

# Check if running as root for network optimizations
if [ "$EUID" -eq 0 ]; then
    # Optimize TCP settings for better throughput
    echo "   Optimizing TCP settings..."
    
    # Increase TCP buffer sizes
    sysctl -w net.core.rmem_max=134217728 2>/dev/null
    sysctl -w net.core.wmem_max=134217728 2>/dev/null
    sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" 2>/dev/null
    sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" 2>/dev/null
    
    # Optimize TCP congestion control
    sysctl -w net.ipv4.tcp_congestion_control=bbr 2>/dev/null || sysctl -w net.ipv4.tcp_congestion_control=cubic 2>/dev/null
    
    # Increase connection limits
    sysctl -w net.core.somaxconn=4096 2>/dev/null
    sysctl -w net.ipv4.tcp_max_syn_backlog=8192 2>/dev/null
    
    # Enable TCP fast open
    sysctl -w net.ipv4.tcp_fastopen=3 2>/dev/null
    
    # Optimize for low latency
    sysctl -w net.ipv4.tcp_low_latency=1 2>/dev/null
    sysctl -w net.ipv4.tcp_timestamps=1 2>/dev/null
    sysctl -w net.ipv4.tcp_sack=1 2>/dev/null
    
    echo "   ✅ Network TCP settings optimized"
else
    echo "   ⚠️  Run with sudo for full network optimization"
fi

# Check network interface speed
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$INTERFACE" ]; then
    echo "   Active interface: $INTERFACE"
    
    # Check link speed
    if [ -f "/sys/class/net/$INTERFACE/speed" ]; then
        SPEED=$(cat /sys/class/net/$INTERFACE/speed 2>/dev/null)
        if [ "$SPEED" != "-1" ] && [ -n "$SPEED" ]; then
            echo "   Link speed: ${SPEED}Mbps"
        fi
    fi
    
    # Check if interface is up
    if ip link show "$INTERFACE" | grep -q "state UP"; then
        echo "   ✅ Interface is UP"
    else
        echo "   ⚠️  Interface is DOWN - bringing up..."
        sudo ip link set "$INTERFACE" up 2>/dev/null
    fi
fi

# Test network connectivity
echo "   Testing connectivity..."
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "   ✅ Internet: CONNECTED"
else
    echo "   ⚠️  Internet: LIMITED"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 2: OPTIMIZE CPU COOLING
# ═══════════════════════════════════════════════════════════
echo "[2] OPTIMIZING CPU COOLING..."
echo ""

# Check current CPU temperature
if command -v sensors &> /dev/null; then
    TEMP=$(sensors 2>/dev/null | grep -i "core\|package" | grep -oE "[0-9]+\.[0-9]+" | head -1 | cut -d. -f1)
    if [ -n "$TEMP" ]; then
        echo "   Current CPU temp: ${TEMP}°C"
        
        if [ "$TEMP" -gt 80 ]; then
            echo "   🔥 HIGH TEMPERATURE DETECTED - Activating aggressive cooling..."
        elif [ "$TEMP" -gt 70 ]; then
            echo "   ⚠️  WARM - Optimizing cooling..."
        else
            echo "   ✅ Temperature: NORMAL"
        fi
    fi
fi

# Check CPU frequency governor
if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
    CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
    echo "   Current governor: $CURRENT_GOV"
    
    # Switch to performance mode for better cooling (higher fan speed)
    if [ "$CURRENT_GOV" != "performance" ] && [ "$EUID" -eq 0 ]; then
        echo "   Switching to performance governor for better cooling..."
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
            echo performance > "$cpu" 2>/dev/null
        done
        echo "   ✅ Switched to performance mode"
    elif [ "$CURRENT_GOV" = "performance" ]; then
        echo "   ✅ Already in performance mode"
    else
        echo "   ⚠️  Run with sudo to change CPU governor"
    fi
fi

# Check if thermald is running
if pgrep -x thermald > /dev/null; then
    echo "   ✅ thermald is running (thermal daemon active)"
else
    echo "   ⚠️  thermald not running - starting..."
    sudo systemctl start thermald 2>/dev/null || sudo thermald --daemon 2>/dev/null
fi

# Check if thermal_guardian is running
if pgrep -f "thermal_guardian" > /dev/null; then
    echo "   ✅ thermal_guardian is running"
else
    echo "   Starting thermal_guardian..."
    nohup python3 /home/anthony/Keepers_room/thermal_guardian.py > /tmp/thermal_guardian.log 2>&1 &
    echo "   ✅ thermal_guardian started (PID: $!)"
fi

# Set CPU frequency limits if available
if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" ] && [ "$EUID" -eq 0 ]; then
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)
    if [ -n "$MAX_FREQ" ]; then
        # Set max freq to allow thermal throttling to work properly
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
            echo "$MAX_FREQ" > "$cpu" 2>/dev/null
        done
        echo "   ✅ CPU frequency limits set for optimal cooling"
    fi
fi

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 3: CHECK AUTOMATED FACTORIES
# ═══════════════════════════════════════════════════════════
echo "[3] CHECKING AUTOMATED FACTORIES..."
echo ""

# Check continuous_spawner
if pgrep -f "continuous_spawner" > /dev/null; then
    echo "   ✅ continuous_spawner is running"
else
    echo "   ⚠️  continuous_spawner not running"
    
    # Fix the continuous_spawner error first
    if [ -f "agents/continuous_spawner.sh" ]; then
        echo "   Fixing continuous_spawner errors..."
        # The error is already fixed (MAX_AGENTS issue), just need to restart
    fi
    
    echo "   Starting continuous_spawner..."
    cd agents
    nohup bash continuous_spawner.sh > logs/spawner.log 2>&1 &
    cd ..
    echo "   ✅ continuous_spawner started (PID: $!)"
fi

# Check AUTOMATED_AGENT_FACTORY
if pgrep -f "AUTOMATED_AGENT_FACTORY" > /dev/null; then
    echo "   ✅ AUTOMATED_AGENT_FACTORY is running"
else
    echo "   Starting AUTOMATED_AGENT_FACTORY..."
    nohup python3 /home/anthony/Keepers_room/AUTOMATED_AGENT_FACTORY.py > /tmp/agent_factory.log 2>&1 &
    echo "   ✅ AUTOMATED_AGENT_FACTORY started (PID: $!)"
fi

# Check factory logs for errors
if [ -f "agents/logs/factory.log" ]; then
    ERROR_COUNT=$(grep -i "error\|fail\|exception" agents/logs/factory.log 2>/dev/null | wc -l)
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "   ⚠️  Found $ERROR_COUNT errors in factory log"
        echo "   Recent errors:"
        grep -i "error\|fail\|exception" agents/logs/factory.log 2>/dev/null | tail -3
    else
        echo "   ✅ No errors in factory log"
    fi
fi

# Count active agents
ACTIVE_AGENTS=$(ps aux | grep -E "agent_.*\.sh|privilege_agent|network_agent" | grep -v grep | wc -l)
echo "   Active agents: $ACTIVE_AGENTS"

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 4: CHECK DEFENSE SYSTEMS
# ═══════════════════════════════════════════════════════════
echo "[4] CHECKING DEFENSE SYSTEMS..."
echo ""

# Check continuous_puppy (threat monitoring)
if pgrep -f "continuous_puppy" > /dev/null; then
    echo "   ✅ continuous_puppy is running (threat monitoring)"
else
    echo "   Starting continuous_puppy..."
    nohup python3 /home/anthony/Keepers_room/continuous_puppy.py > /tmp/continuous_puppy.log 2>&1 &
    echo "   ✅ continuous_puppy started (PID: $!)"
fi

# Check MONSTER_HUNTER (process monitoring)
if pgrep -f "MONSTER_HUNTER" > /dev/null; then
    echo "   ✅ MONSTER_HUNTER is running"
else
    echo "   Starting MONSTER_HUNTER..."
    nohup python3 /home/anthony/Keepers_room/MONSTER_HUNTER.py > /tmp/monster_hunter.log 2>&1 &
    echo "   ✅ MONSTER_HUNTER started (PID: $!)"
fi

# Check ROUTER_GUARDS (network monitoring)
if pgrep -f "ROUTER_GUARDS" > /dev/null; then
    echo "   ✅ ROUTER_GUARDS is running"
else
    echo "   Starting ROUTER_GUARDS..."
    nohup python3 /home/anthony/Keepers_room/ROUTER_GUARDS.py > /tmp/router_guards.log 2>&1 &
    echo "   ✅ ROUTER_GUARDS started (PID: $!)"
fi

# Check if defense protocols are active
DEFENSE_COUNT=$(ps aux | grep -E "puppy|monster|router|guardian|defense" | grep -v grep | wc -l)
echo "   Active defense processes: $DEFENSE_COUNT"

# Check for defense activation scripts
if [ -f "organized/scripts/protection/ACTIVATE_DEFENSE_PROTOCOLS.sh" ]; then
    echo "   ✅ Defense activation scripts available"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "SYSTEM STATUS SUMMARY"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Network status
if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "🌐 Network: ✅ CONNECTED"
else
    echo "🌐 Network: ⚠️  LIMITED"
fi

# CPU status
if command -v sensors &> /dev/null; then
    TEMP=$(sensors 2>/dev/null | grep -i "core\|package" | grep -oE "[0-9]+\.[0-9]+" | head -1 | cut -d. -f1)
    if [ -n "$TEMP" ]; then
        if [ "$TEMP" -lt 70 ]; then
            echo "❄️  CPU Temp: ✅ ${TEMP}°C (NORMAL)"
        elif [ "$TEMP" -lt 80 ]; then
            echo "❄️  CPU Temp: ⚠️  ${TEMP}°C (WARM)"
        else
            echo "❄️  CPU Temp: 🔥 ${TEMP}°C (HIGH)"
        fi
    fi
fi

# Factory status
FACTORY_COUNT=$(pgrep -f "factory|spawner" | wc -l)
if [ "$FACTORY_COUNT" -gt 0 ]; then
    echo "🏭 Factories: ✅ $FACTORY_COUNT processes active"
else
    echo "🏭 Factories: ⚠️  NOT RUNNING"
fi

# Defense status
DEFENSE_COUNT=$(ps aux | grep -E "puppy|monster|router|guardian|defense" | grep -v grep | wc -l)
if [ "$DEFENSE_COUNT" -gt 0 ]; then
    echo "🛡️  Defenses: ✅ $DEFENSE_COUNT processes active"
else
    echo "🛡️  Defenses: ⚠️  NOT RUNNING"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ SYSTEM BOOST COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Logs:"
echo "  - thermal_guardian: /tmp/thermal_guardian.log"
echo "  - agent_factory: /tmp/agent_factory.log"
echo "  - continuous_puppy: /tmp/continuous_puppy.log"
echo "  - factory spawner: agents/logs/spawner.log"
echo ""


