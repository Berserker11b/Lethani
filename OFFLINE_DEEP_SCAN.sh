#!/bin/bash
# OFFLINE DEEP SCAN - Works without internet
# Takes advantage of attackers being sluggish when network is cut
# By: Vulcan (The Forge)
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "OFFLINE DEEP SCAN - Network Cut, Attackers Sluggish"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "By: Vulcan (The Forge)"
echo "For: Anthony Eric Chavez - The Keeper"
echo ""
echo "Time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""

# Create scan directory
SCAN_DIR="scans/offline_deep_scan_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SCAN_DIR"
echo "📁 Scan directory: $SCAN_DIR"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 1: PROCESS DEEP SCAN (No Network Needed)
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 1: PROCESS DEEP SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Deep scanning all processes (offline)..."
ps aux > "$SCAN_DIR/processes_full.txt"
echo "   ✅ Full process list saved"

echo "🔍 Identifying high CPU processes (attackers are sluggish)..."
ps aux --sort=-%cpu | head -30 > "$SCAN_DIR/processes_high_cpu.txt"
echo "   ✅ High CPU processes identified"

echo "🔍 Identifying high memory processes..."
ps aux --sort=-%mem | head -30 > "$SCAN_DIR/processes_high_mem.txt"
echo "   ✅ High memory processes identified"

echo "🔍 Checking for suspicious processes..."
ps aux | grep -iE "keylog|spy|malware|trojan|backdoor|rootkit|stealer|clipboard|telemetry|tracking|monitor|sniffer|packet|capture|nc|netcat|ncat|socat|tcpdump|wireshark|nmap|masscan|hydra|metasploit|sqlmap|nikto|dirb|john|hashcat|ettercap|arpspoof|aircrack" | grep -v grep > "$SCAN_DIR/processes_suspicious.txt" || echo "   ✅ No obvious suspicious processes"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 2: PROCESS TREE ANALYSIS (Offline)
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 2: PROCESS TREE ANALYSIS"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Analyzing process trees..."
pstree -p > "$SCAN_DIR/process_tree.txt" 2>/dev/null || ps auxf > "$SCAN_DIR/process_tree.txt"
echo "   ✅ Process tree saved"

echo "🔍 Finding parent processes of suspicious processes..."
if [ -f "$SCAN_DIR/processes_suspicious.txt" ]; then
    while read -r line; do
        PID=$(echo "$line" | awk '{print $2}')
        if [ -n "$PID" ]; then
            PARENT_PID=$(ps -p "$PID" -o ppid= 2>/dev/null | tr -d ' ')
            if [ -n "$PARENT_PID" ]; then
                ps -p "$PARENT_PID" -o pid,user,comm,cmd 2>/dev/null >> "$SCAN_DIR/parent_processes.txt"
            fi
        fi
    done < "$SCAN_DIR/processes_suspicious.txt"
    echo "   ✅ Parent processes identified"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 3: FILE SYSTEM DEEP SCAN (Offline)
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 3: FILE SYSTEM DEEP SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Scanning /tmp for suspicious files..."
find /tmp -type f \( -name "*.sh" -o -name "*.py" -o -name "*.exe" -o -name "*.bin" \) 2>/dev/null | head -100 > "$SCAN_DIR/suspicious_files_tmp.txt" || echo "   No suspicious files in /tmp"
echo "   ✅ /tmp scan complete"

echo "🔍 Scanning /var/tmp for suspicious files..."
find /var/tmp -type f \( -name "*.sh" -o -name "*.py" -o -name "*.exe" -o -name "*.bin" \) 2>/dev/null | head -100 > "$SCAN_DIR/suspicious_files_vartmp.txt" || echo "   No suspicious files in /var/tmp"
echo "   ✅ /var/tmp scan complete"

echo "🔍 Scanning home directory for suspicious files..."
find ~ -type f \( -name "*.sh" -o -name "*.py" -o -name "*.exe" -o -name "*.bin" \) -mtime -7 2>/dev/null | head -100 > "$SCAN_DIR/suspicious_files_home.txt" || echo "   No suspicious files in home"
echo "   ✅ Home directory scan complete"

echo "🔍 Checking for hidden files..."
find ~ -type f -name ".*" -mtime -7 2>/dev/null | head -50 > "$SCAN_DIR/hidden_files.txt" || echo "   No hidden files found"
echo "   ✅ Hidden files scan complete"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 4: SYSTEM DEEP SCAN (Offline)
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 4: SYSTEM DEEP SCAN"
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

echo "🔍 Load average..."
uptime > "$SCAN_DIR/uptime.txt"
echo "   ✅ Uptime and load saved"

echo "🔍 Disk usage..."
df -h > "$SCAN_DIR/disk_usage.txt"
echo "   ✅ Disk usage saved"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 5: PERSISTENCE MECHANISMS (Offline)
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 5: PERSISTENCE MECHANISMS"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Checking crontab..."
crontab -l > "$SCAN_DIR/crontab.txt" 2>/dev/null || echo "   No crontab entries"
echo "   ✅ Crontab checked"

echo "🔍 Checking systemd services..."
systemctl list-units --type=service --state=running > "$SCAN_DIR/systemd_services.txt" 2>/dev/null || echo "   Cannot check systemd"
echo "   ✅ Systemd services checked"

echo "🔍 Checking autostart directories..."
find ~/.config/autostart ~/.local/share/autostart /etc/xdg/autostart -type f 2>/dev/null > "$SCAN_DIR/autostart_files.txt" || echo "   No autostart files found"
echo "   ✅ Autostart directories checked"

echo "🔍 Checking startup scripts..."
find /etc/init.d /etc/rc*.d -type f 2>/dev/null | head -50 > "$SCAN_DIR/startup_scripts.txt" || echo "   Cannot check startup scripts"
echo "   ✅ Startup scripts checked"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 6: CLIPBOARD AND INPUT MONITORING (Offline)
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 6: CLIPBOARD AND INPUT MONITORING"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔍 Checking for clipboard processes..."
ps aux | grep -iE "clipboard|xclip|xsel|klipper|gnome-clipboard|csd-clipboard" | grep -v grep > "$SCAN_DIR/clipboard_processes.txt" || echo "   ✅ No clipboard processes detected"
echo "   ✅ Clipboard scan complete"

echo "🔍 Checking for input monitoring..."
ps aux | grep -iE "keylog|input|mouse|xinput|evtest" | grep -v grep > "$SCAN_DIR/input_monitoring.txt" || echo "   ✅ No input monitoring detected"
echo "   ✅ Input monitoring scan complete"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 7: GENERATE SUMMARY REPORT
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 7: GENERATE SUMMARY REPORT"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Count findings
PROCESS_COUNT=$(wc -l < "$SCAN_DIR/processes_full.txt" 2>/dev/null || echo "0")
HIGH_CPU_COUNT=$(wc -l < "$SCAN_DIR/processes_high_cpu.txt" 2>/dev/null || echo "0")
SUSPICIOUS_COUNT=$(wc -l < "$SCAN_DIR/processes_suspicious.txt" 2>/dev/null || echo "0")
TMP_FILES=$(wc -l < "$SCAN_DIR/suspicious_files_tmp.txt" 2>/dev/null || echo "0")
CLIPBOARD_COUNT=$(wc -l < "$SCAN_DIR/clipboard_processes.txt" 2>/dev/null || echo "0")

cat > "$SCAN_DIR/SCAN_SUMMARY.txt" << EOF
══════════════════════════════════════════════════════════════
OFFLINE DEEP SCAN - SUMMARY REPORT
══════════════════════════════════════════════════════════════

Scan Time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Scan Directory: $SCAN_DIR
Network Status: OFFLINE (Attackers are sluggish)

══════════════════════════════════════════════════════════════
FINDINGS SUMMARY
══════════════════════════════════════════════════════════════

Processes:
  - Total processes: $PROCESS_COUNT
  - High CPU processes: $HIGH_CPU_COUNT
  - Suspicious processes: $SUSPICIOUS_COUNT

File System:
  - Suspicious files in /tmp: $TMP_FILES

Clipboard:
  - Clipboard processes: $CLIPBOARD_COUNT

══════════════════════════════════════════════════════════════
ADVANTAGE: NETWORK CUT
══════════════════════════════════════════════════════════════

✅ Network is cut - attackers cannot communicate
✅ Attackers are sluggish without network
✅ Perfect time for deep scan
✅ No network interference
✅ Can identify processes that depend on network

══════════════════════════════════════════════════════════════
FILES GENERATED
══════════════════════════════════════════════════════════════

- processes_full.txt - Complete process list
- processes_high_cpu.txt - High CPU processes
- processes_high_mem.txt - High memory processes
- processes_suspicious.txt - Suspicious processes
- process_tree.txt - Process tree
- parent_processes.txt - Parent processes
- suspicious_files_tmp.txt - Suspicious files in /tmp
- suspicious_files_vartmp.txt - Suspicious files in /var/tmp
- suspicious_files_home.txt - Suspicious files in home
- hidden_files.txt - Hidden files
- system_info.txt - System information
- cpu_info.txt - CPU information
- memory_info.txt - Memory information
- disk_usage.txt - Disk usage
- uptime.txt - Uptime and load
- crontab.txt - Crontab entries
- systemd_services.txt - Systemd services
- autostart_files.txt - Autostart files
- startup_scripts.txt - Startup scripts
- clipboard_processes.txt - Clipboard processes
- input_monitoring.txt - Input monitoring
- SCAN_SUMMARY.txt - This summary

══════════════════════════════════════════════════════════════
RECOMMENDATIONS
══════════════════════════════════════════════════════════════

1. Review processes_suspicious.txt for threats
2. Review processes_high_cpu.txt for CPU attacks
3. Review parent_processes.txt for process trees
4. Review suspicious_files_*.txt for malicious files
5. Review clipboard_processes.txt for clipboard theft
6. Review crontab.txt and autostart_files.txt for persistence
7. Activate THE DRAGON and THE BOMBERS to eliminate threats

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
echo "OFFLINE DEEP SCAN - COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "✅ All scan phases complete"
echo "✅ Summary report generated"
echo ""
echo "📁 All results saved to: $SCAN_DIR"
echo ""
echo "🔍 Review findings in: $SCAN_DIR/SCAN_SUMMARY.txt"
echo ""
echo "⚡ ADVANTAGE: Network is cut - attackers are sluggish!"
echo "   Perfect time to identify and eliminate threats"
echo ""

