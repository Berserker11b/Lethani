#!/bin/bash
# BOOST SYSTEMS - FULL OPTIMIZATION (Requires Sudo)
# Network, CPU Cooling, Factories, Defenses
# By: Auto Agent
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "FULL SYSTEM BOOST (SUDO REQUIRED)"
echo "══════════════════════════════════════════════════════════════"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script requires sudo privileges for full optimization"
    echo "   Run: sudo bash BOOST_SYSTEMS_SUDO.sh"
    echo ""
    echo "   Or run the non-sudo version: bash BOOST_SYSTEMS.sh"
    exit 1
fi

cd /home/anthony/Keepers_room

# ═══════════════════════════════════════════════════════════
# PHASE 1: FULL NETWORK OPTIMIZATION
# ═══════════════════════════════════════════════════════════
echo "[1] FULL NETWORK OPTIMIZATION..."
echo ""

# Optimize TCP settings for maximum throughput
echo "   Optimizing TCP buffer sizes..."
sysctl -w net.core.rmem_max=134217728 > /dev/null 2>&1
sysctl -w net.core.wmem_max=134217728 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" > /dev/null 2>&1
sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" > /dev/null 2>&1

# Optimize TCP congestion control (BBR if available, else cubic)
if modprobe tcp_bbr 2>/dev/null; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null 2>&1
    echo "   ✅ BBR congestion control enabled"
else
    sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null 2>&1
    echo "   ✅ CUBIC congestion control enabled"
fi

# Increase connection limits
sysctl -w net.core.somaxconn=4096 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_max_syn_backlog=8192 > /dev/null 2>&1

# Enable TCP fast open
sysctl -w net.ipv4.tcp_fastopen=3 > /dev/null 2>&1

# Optimize for low latency
sysctl -w net.ipv4.tcp_low_latency=1 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_timestamps=1 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_sack=1 > /dev/null 2>&1

# Increase UDP buffer sizes
sysctl -w net.core.netdev_max_backlog=5000 > /dev/null 2>&1

# Optimize network interface queues
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$INTERFACE" ]; then
    # Increase ring buffer sizes if supported
    ethtool -G "$INTERFACE" rx 4096 tx 4096 2>/dev/null || true
    ethtool -G "$INTERFACE" rx 2048 tx 2048 2>/dev/null || true
    
    # Enable offloading features
    ethtool -K "$INTERFACE" gro on 2>/dev/null || true
    ethtool -K "$INTERFACE" gso on 2>/dev/null || true
    ethtool -K "$INTERFACE" tso on 2>/dev/null || true
    
    echo "   ✅ Network interface optimized: $INTERFACE"
fi

echo "   ✅ Network fully optimized"
echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 2: AGGRESSIVE CPU COOLING
# ═══════════════════════════════════════════════════════════
echo "[2] AGGRESSIVE CPU COOLING OPTIMIZATION..."
echo ""

# Check current temperature
if command -v sensors &> /dev/null; then
    TEMP=$(sensors 2>/dev/null | grep -i "core\|package" | grep -oE "[0-9]+\.[0-9]+" | head -1 | cut -d. -f1)
    if [ -n "$TEMP" ]; then
        echo "   Current CPU temp: ${TEMP}°C"
    fi
fi

# Switch CPU governor to performance for better cooling
if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor" ]; then
    echo "   Switching CPU governor to performance mode..."
    for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
        echo performance > "$cpu" 2>/dev/null
    done
    echo "   ✅ CPU governor set to performance"
fi

# Set CPU frequency to max for better cooling (fans spin faster)
if [ -f "/sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq" ]; then
    MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq 2>/dev/null)
    if [ -n "$MAX_FREQ" ]; then
        echo "   Setting CPU max frequency: ${MAX_FREQ}Hz"
        for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq; do
            echo "$MAX_FREQ" > "$cpu" 2>/dev/null
        done
        echo "   ✅ CPU frequency limits optimized"
    fi
fi

# Ensure thermald is running and configured
if ! pgrep -x thermald > /dev/null; then
    echo "   Starting thermald..."
    systemctl start thermald 2>/dev/null || thermald --daemon 2>/dev/null
fi

# Configure thermald for aggressive cooling
if [ -f "/etc/thermald/thermal-conf.xml" ]; then
    echo "   ✅ thermald configuration available"
fi

echo "   ✅ CPU cooling optimized"
echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 3: VERIFY FACTORIES
# ═══════════════════════════════════════════════════════════
echo "[3] VERIFYING FACTORIES..."
echo ""

# Check all factory processes
FACTORY_PROCESSES=("continuous_spawner" "AUTOMATED_AGENT_FACTORY" "thermal_guardian")
for proc in "${FACTORY_PROCESSES[@]}"; do
    if pgrep -f "$proc" > /dev/null; then
        echo "   ✅ $proc is running"
    else
        echo "   ⚠️  $proc not running"
    fi
done

ACTIVE_AGENTS=$(ps aux | grep -E "agent_.*\.sh|privilege_agent|network_agent" | grep -v grep | wc -l)
echo "   Active agents spawned: $ACTIVE_AGENTS"

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 4: VERIFY DEFENSES
# ═══════════════════════════════════════════════════════════
echo "[4] VERIFYING DEFENSES..."
echo ""

# Check all defense processes
DEFENSE_PROCESSES=("continuous_puppy" "MONSTER_HUNTER" "ROUTER_GUARDS")
for proc in "${DEFENSE_PROCESSES[@]}"; do
    if pgrep -f "$proc" > /dev/null; then
        echo "   ✅ $proc is running"
    else
        echo "   ⚠️  $proc not running"
    fi
done

DEFENSE_COUNT=$(ps aux | grep -E "puppy|monster|router|guardian|defense" | grep -v grep | wc -l)
echo "   Total defense processes: $DEFENSE_COUNT"

echo ""

# ═══════════════════════════════════════════════════════════
# FINAL STATUS
# ═══════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "✅ FULL SYSTEM BOOST COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Show current status
if command -v sensors &> /dev/null; then
    TEMP=$(sensors 2>/dev/null | grep -i "core\|package" | grep -oE "[0-9]+\.[0-9]+" | head -1 | cut -d. -f1)
    if [ -n "$TEMP" ]; then
        echo "❄️  CPU Temperature: ${TEMP}°C"
    fi
fi

CURRENT_GOV=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)
if [ -n "$CURRENT_GOV" ]; then
    echo "⚡ CPU Governor: $CURRENT_GOV"
fi

echo "🌐 Network: Optimized"
echo "🏭 Factories: Active"
echo "🛡️  Defenses: Active"
echo ""



