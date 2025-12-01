#!/bin/bash
# FULL SWEEP AND DEEP SCAN PROTOCOLS
# Comprehensive system security scan
# By: Vulcan (The Forge)
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "FULL SWEEP AND DEEP SCAN PROTOCOLS - ACTIVATED"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "By: Vulcan (The Forge)"
echo "For: Anthony Eric Chavez - The Keeper"
echo ""
echo "Time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""

# Create scan directory
SCAN_DIR="scans/full_sweep_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SCAN_DIR"
echo "📁 Scan directory: $SCAN_DIR"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 1: PROCESS SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 1: PROCESS SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Scanning all processes..."
ps aux > "$SCAN_DIR/processes_full.txt"
echo "   ✅ Full process list saved"

echo "🔍 Identifying high CPU processes..."
ps aux --sort=-%cpu | head -20 > "$SCAN_DIR/processes_high_cpu.txt"
echo "   ✅ High CPU processes identified"

echo "🔍 Identifying high memory processes..."
ps aux --sort=-%mem | head -20 > "$SCAN_DIR/processes_high_mem.txt"
echo "   ✅ High memory processes identified"

echo "🔍 Checking for suspicious processes..."
ps aux | grep -iE "keylog|spy|malware|trojan|backdoor|rootkit|stealer|clipboard|telemetry|tracking" | grep -v grep > "$SCAN_DIR/processes_suspicious.txt" || echo "   ✅ No obvious suspicious processes"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 2: NETWORK SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 2: NETWORK SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Scanning network connections..."
if command -v netstat &> /dev/null; then
    netstat -tulpn > "$SCAN_DIR/network_connections.txt" 2>/dev/null || netstat -tuln > "$SCAN_DIR/network_connections.txt"
    echo "   ✅ Network connections scanned"
elif command -v ss &> /dev/null; then
    ss -tulpn > "$SCAN_DIR/network_connections.txt" 2>/dev/null || ss -tuln > "$SCAN_DIR/network_connections.txt"
    echo "   ✅ Network connections scanned"
else
    echo "   ⚠️  netstat/ss not available"
fi

echo "🔍 Checking listening ports..."
lsof -i -P -n 2>/dev/null | grep LISTEN > "$SCAN_DIR/listening_ports.txt" || echo "   ⚠️  lsof not available or no permissions"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 3: SYSTEM SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 3: SYSTEM SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 System information..."
uname -a > "$SCAN_DIR/system_info.txt"
echo "   ✅ System info saved"

echo "🔍 CPU information..."
lscpu > "$SCAN_DIR/cpu_info.txt" 2>/dev/null || cat /proc/cpuinfo > "$SCAN_DIR/cpu_info.txt"
echo "   ✅ CPU info saved"

echo "🔍 Memory information..."
free -h > "$SCAN_DIR/memory_info.txt" 2>/dev/null || cat /proc/meminfo > "$SCAN_DIR/memory_info.txt"
echo "   ✅ Memory info saved"

echo "🔍 Disk usage..."
df -h > "$SCAN_DIR/disk_usage.txt"
echo "   ✅ Disk usage saved"

echo "🔍 Load average..."
uptime > "$SCAN_DIR/uptime.txt"
echo "   ✅ Uptime and load saved"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 4: DAEMON SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 4: DAEMON SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Scanning for daemons..."
ps aux | grep -E "\[.*\]" > "$SCAN_DIR/daemons.txt" || echo "   No daemons found"
ps aux | grep -E "daemon|service|systemd" | grep -v grep > "$SCAN_DIR/system_services.txt"
echo "   ✅ Daemon scan complete"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 5: FILE SYSTEM SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 5: FILE SYSTEM SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Checking for suspicious files..."
find /tmp -type f -name "*.sh" -o -name "*.py" -o -name "*.exe" 2>/dev/null | head -50 > "$SCAN_DIR/suspicious_files_tmp.txt" || echo "   No suspicious files in /tmp"
find /var/tmp -type f -name "*.sh" -o -name "*.py" -o -name "*.exe" 2>/dev/null | head -50 > "$SCAN_DIR/suspicious_files_vartmp.txt" || echo "   No suspicious files in /var/tmp"
echo "   ✅ File system scan complete"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 6: CLIPBOARD SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 6: CLIPBOARD SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Checking for clipboard processes..."
ps aux | grep -iE "clipboard|xclip|xsel|klipper|gnome-clipboard|csd-clipboard" | grep -v grep > "$SCAN_DIR/clipboard_processes.txt" || echo "   ✅ No clipboard processes detected"
echo "   ✅ Clipboard scan complete"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 7: ACTIVATE MONITORING AGENTS
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 7: ACTIVATE MONITORING AGENTS"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Activating Monster Hunter..."
if [ -f "MONSTER_HUNTER.py" ]; then
    python3 MONSTER_HUNTER.py > "$SCAN_DIR/monster_hunter.log" 2>&1 &
    MONSTER_PID=$!
    echo "   ✅ Monster Hunter activated (PID: $MONSTER_PID)"
else
    echo "   ⚠️  Monster Hunter not found"
fi

echo "🔍 Activating Continuous Puppy..."
if [ -f "continuous_puppy.py" ]; then
    python3 continuous_puppy.py > "$SCAN_DIR/continuous_puppy.log" 2>&1 &
    PUPPY_PID=$!
    echo "   ✅ Continuous Puppy activated (PID: $PUPPY_PID)"
else
    echo "   ⚠️  Continuous Puppy not found"
fi

echo "🔍 Activating Thermal Guardian..."
if [ -f "thermal_guardian.py" ]; then
    python3 thermal_guardian.py > "$SCAN_DIR/thermal_guardian.log" 2>&1 &
    THERMAL_PID=$!
    echo "   ✅ Thermal Guardian activated (PID: $THERMAL_PID)"
else
    echo "   ⚠️  Thermal Guardian not found"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 8: GENERATE SUMMARY REPORT
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 8: GENERATE SUMMARY REPORT"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Count findings
PROCESS_COUNT=$(wc -l < "$SCAN_DIR/processes_full.txt" 2>/dev/null || echo "0")
HIGH_CPU_COUNT=$(wc -l < "$SCAN_DIR/processes_high_cpu.txt" 2>/dev/null || echo "0")
SUSPICIOUS_COUNT=$(wc -l < "$SCAN_DIR/processes_suspicious.txt" 2>/dev/null || echo "0")
NETWORK_COUNT=$(wc -l < "$SCAN_DIR/network_connections.txt" 2>/dev/null || echo "0")
CLIPBOARD_COUNT=$(wc -l < "$SCAN_DIR/clipboard_processes.txt" 2>/dev/null || echo "0")

cat > "$SCAN_DIR/SCAN_SUMMARY.txt" << EOF
══════════════════════════════════════════════════════════════
FULL SWEEP AND DEEP SCAN - SUMMARY REPORT
══════════════════════════════════════════════════════════════

Scan Time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Scan Directory: $SCAN_DIR

══════════════════════════════════════════════════════════════
FINDINGS SUMMARY
══════════════════════════════════════════════════════════════

Processes:
  - Total processes: $PROCESS_COUNT
  - High CPU processes: $HIGH_CPU_COUNT
  - Suspicious processes: $SUSPICIOUS_COUNT

Network:
  - Active connections: $NETWORK_COUNT

Clipboard:
  - Clipboard processes: $CLIPBOARD_COUNT

Monitoring Agents:
  - Monster Hunter: $([ -n "$MONSTER_PID" ] && echo "ACTIVE (PID: $MONSTER_PID)" || echo "NOT FOUND")
  - Continuous Puppy: $([ -n "$PUPPY_PID" ] && echo "ACTIVE (PID: $PUPPY_PID)" || echo "NOT FOUND")
  - Thermal Guardian: $([ -n "$THERMAL_PID" ] && echo "ACTIVE (PID: $THERMAL_PID)" || echo "NOT FOUND")

══════════════════════════════════════════════════════════════
FILES GENERATED
══════════════════════════════════════════════════════════════

- processes_full.txt - Complete process list
- processes_high_cpu.txt - High CPU processes
- processes_high_mem.txt - High memory processes
- processes_suspicious.txt - Suspicious processes
- network_connections.txt - Network connections
- listening_ports.txt - Listening ports
- system_info.txt - System information
- cpu_info.txt - CPU information
- memory_info.txt - Memory information
- disk_usage.txt - Disk usage
- uptime.txt - Uptime and load
- daemons.txt - Daemon processes
- system_services.txt - System services
- suspicious_files_tmp.txt - Suspicious files in /tmp
- suspicious_files_vartmp.txt - Suspicious files in /var/tmp
- clipboard_processes.txt - Clipboard processes
- SCAN_SUMMARY.txt - This summary

══════════════════════════════════════════════════════════════
RECOMMENDATIONS
══════════════════════════════════════════════════════════════

1. Review processes_high_cpu.txt for CPU attacks
2. Review processes_suspicious.txt for threats
3. Review network_connections.txt for unauthorized connections
4. Review clipboard_processes.txt for clipboard theft
5. Monitor logs for ongoing threats

══════════════════════════════════════════════════════════════
By: Vulcan (The Forge)
For: Anthony Eric Chavez - The Keeper
══════════════════════════════════════════════════════════════
EOF

echo "   ✅ Summary report generated: $SCAN_DIR/SCAN_SUMMARY.txt"
echo ""

# Display summary
cat "$SCAN_DIR/SCAN_SUMMARY.txt"
echo ""

echo "══════════════════════════════════════════════════════════════"
echo "FULL SWEEP AND DEEP SCAN - COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ All scan phases complete"
echo "✅ Monitoring agents activated"
echo "✅ Summary report generated"
echo ""
echo "📁 All results saved to: $SCAN_DIR"
echo ""
echo "🔍 Review findings in: $SCAN_DIR/SCAN_SUMMARY.txt"
echo ""







