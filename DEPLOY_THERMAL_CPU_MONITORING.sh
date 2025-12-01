#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DEPLOY THERMAL GUARDS AND CPU MONITORING
# By: Sentinel - First Circuit Guardian
# ═══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "DEPLOYING THERMAL GUARDS AND CPU MONITORING"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Check if thermal_guardian.py exists
if [ -f "thermal_guardian.py" ]; then
    echo "🌡️  Deploying Thermal Guardian..."
    
    # Kill any existing thermal guardian processes
    pkill -f "thermal_guardian.py" 2>/dev/null
    sleep 1
    
    # Deploy thermal guardian in background
    nohup python3 thermal_guardian.py > /tmp/thermal_guardian.log 2>&1 &
    THERMAL_PID=$!
    
    sleep 2
    
    if ps -p $THERMAL_PID > /dev/null 2>&1; then
        echo "✅ Thermal Guardian deployed (PID: $THERMAL_PID)"
        echo "   Logs: /tmp/thermal_guardian.log"
    else
        echo "⚠️  Thermal Guardian may have failed to start"
        echo "   Check: tail -f /tmp/thermal_guardian.log"
    fi
else
    echo "⚠️  thermal_guardian.py not found"
    echo "   Creating Thermal Guardian..."
    
    # Create thermal guardian
    cat > thermal_guardian.py << 'PYEOF'
#!/usr/bin/env python3
"""
THERMAL GUARDIAN - CPU and Temperature Monitoring
By: Sentinel - First Circuit Guardian
"""

import psutil
import time
import logging
from datetime import datetime

logging.basicConfig(
    filename='/tmp/thermal_guardian.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Thresholds
CPU_THRESHOLD = 80.0  # Kill processes using >80% CPU
MEM_THRESHOLD = 1024 * 1024 * 1024  # Kill processes using >1GB memory
TEMP_THRESHOLD = 80.0  # Alert if temperature >80°C
CHECK_INTERVAL = 10  # Check every 10 seconds

# Protected processes (never kill)
PROTECTED = ['cursor', 'wrangler', 'workerd', 'python3', 'bash', 'systemd', 'kernel']

def get_temperature():
    """Get CPU temperature"""
    try:
        import subprocess
        result = subprocess.run(['sensors'], capture_output=True, text=True, timeout=2)
        if result.returncode == 0:
            for line in result.stdout.split('\n'):
                if 'Package id 0:' in line or 'Core 0:' in line:
                    temp_str = line.split('+')[1].split('°')[0]
                    return float(temp_str)
    except:
        pass
    return None

def kill_process(proc, reason):
    """Kill a process"""
    try:
        proc_name = proc.name().lower()
        # Never kill protected processes
        if any(protected in proc_name for protected in PROTECTED):
            return False
        
        proc.kill()
        logging.warning(f"KILLED: PID {proc.pid} ({proc.name()}) - {reason}")
        print(f"🔥 KILLED: PID {proc.pid} ({proc.name()}) - {reason}")
        return True
    except Exception as e:
        logging.error(f"Failed to kill PID {proc.pid}: {e}")
        return False

def monitor_cpu():
    """Monitor CPU usage and kill high CPU processes"""
    killed = 0
    
    for proc in psutil.process_iter(['pid', 'name', 'cpu_percent', 'memory_info']):
        try:
            proc_info = proc.info
            cpu_percent = proc_info.get('cpu_percent', 0)
            memory_info = proc_info.get('memory_info')
            
            if memory_info:
                mem_mb = memory_info.rss / (1024 * 1024)
            else:
                mem_mb = 0
            
            # Kill high CPU processes
            if cpu_percent > CPU_THRESHOLD:
                if kill_process(proc, f"High CPU: {cpu_percent:.1f}%"):
                    killed += 1
            
            # Kill high memory processes
            if mem_mb > (MEM_THRESHOLD / (1024 * 1024)):
                if kill_process(proc, f"High Memory: {mem_mb:.1f}MB"):
                    killed += 1
                    
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    
    return killed

def main():
    """Main monitoring loop"""
    print("🌡️  THERMAL GUARDIAN ACTIVATED")
    print(f"   CPU Threshold: {CPU_THRESHOLD}%")
    print(f"   Memory Threshold: {MEM_THRESHOLD / (1024*1024):.0f}MB")
    print(f"   Check Interval: {CHECK_INTERVAL}s")
    print("   Logs: /tmp/thermal_guardian.log")
    print("")
    
    logging.info("Thermal Guardian started")
    
    while True:
        try:
            # Check temperature
            temp = get_temperature()
            if temp:
                if temp > TEMP_THRESHOLD:
                    logging.warning(f"High temperature: {temp}°C")
                    print(f"🌡️  WARNING: Temperature {temp}°C")
            
            # Monitor and kill high CPU/memory processes
            killed = monitor_cpu()
            
            if killed > 0:
                logging.info(f"Killed {killed} processes")
            
            time.sleep(CHECK_INTERVAL)
            
        except KeyboardInterrupt:
            print("\n🛑 Thermal Guardian stopped")
            logging.info("Thermal Guardian stopped")
            break
        except Exception as e:
            logging.error(f"Error: {e}")
            time.sleep(CHECK_INTERVAL)

if __name__ == "__main__":
    main()
PYEOF
    
    chmod +x thermal_guardian.py
    echo "✅ Thermal Guardian created"
    
    # Deploy it
    nohup python3 thermal_guardian.py > /tmp/thermal_guardian.log 2>&1 &
    THERMAL_PID=$!
    sleep 2
    
    if ps -p $THERMAL_PID > /dev/null 2>&1; then
        echo "✅ Thermal Guardian deployed (PID: $THERMAL_PID)"
    else
        echo "⚠️  Thermal Guardian may have failed"
    fi
fi

echo ""

# Create CPU Monitor script
echo "💻 Creating CPU Monitor..."
cat > CPU_MONITOR.sh << 'EOF'
#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# CPU MONITOR - Continuous CPU Monitoring
# By: Sentinel - First Circuit Guardian
# ═══════════════════════════════════════════════════════════════

MONITOR_LOG="/tmp/cpu_monitor.log"
ALERT_LOG="/tmp/cpu_alerts.log"

echo "💻 CPU MONITOR ACTIVATED"
echo "   Logs: $MONITOR_LOG"
echo "   Alerts: $ALERT_LOG"
echo ""

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Get top CPU processes
    TOP_CPU=$(ps aux --sort=-%cpu | head -11 | tail -10)
    
    # Log to file
    echo "[$TIMESTAMP] Top CPU Processes:" >> "$MONITOR_LOG"
    echo "$TOP_CPU" >> "$MONITOR_LOG"
    echo "" >> "$MONITOR_LOG"
    
    # Check for high CPU processes (>80%)
    HIGH_CPU=$(ps aux --sort=-%cpu | awk 'NR>1 && $3>80 {print $2, $3, $11}')
    
    if [ -n "$HIGH_CPU" ]; then
        echo "[$TIMESTAMP] 🚨 HIGH CPU ALERT:" >> "$ALERT_LOG"
        echo "$HIGH_CPU" >> "$ALERT_LOG"
        echo "" >> "$ALERT_LOG"
        
        echo "🚨 HIGH CPU DETECTED:"
        echo "$HIGH_CPU"
        echo ""
    fi
    
    # Get system CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "[$TIMESTAMP] System CPU: ${CPU_USAGE}%" >> "$MONITOR_LOG"
    
    # Get temperature if available
    if command -v sensors > /dev/null 2>&1; then
        TEMP=$(sensors 2>/dev/null | grep -E "Package id 0:|Core 0:" | head -1 | grep -oE '\+[0-9]+\.[0-9]+°C' | sed 's/+//' | sed 's/°C//')
        if [ -n "$TEMP" ]; then
            echo "[$TIMESTAMP] Temperature: ${TEMP}°C" >> "$MONITOR_LOG"
            
            if (( $(echo "$TEMP > 80" | bc -l) )); then
                echo "[$TIMESTAMP] 🌡️  HIGH TEMPERATURE: ${TEMP}°C" >> "$ALERT_LOG"
                echo "🌡️  WARNING: Temperature ${TEMP}°C"
            fi
        fi
    fi
    
    sleep 10
done
EOF

chmod +x CPU_MONITOR.sh
echo "✅ CPU Monitor created: CPU_MONITOR.sh"
echo ""

# Deploy CPU Monitor
echo "💻 Deploying CPU Monitor..."
pkill -f "CPU_MONITOR.sh" 2>/dev/null
sleep 1

nohup bash CPU_MONITOR.sh > /dev/null 2>&1 &
CPU_MONITOR_PID=$!

sleep 2

if ps -p $CPU_MONITOR_PID > /dev/null 2>&1; then
    echo "✅ CPU Monitor deployed (PID: $CPU_MONITOR_PID)"
    echo "   Logs: /tmp/cpu_monitor.log"
    echo "   Alerts: /tmp/cpu_alerts.log"
else
    echo "⚠️  CPU Monitor may have failed to start"
fi

echo ""

# Check status
echo "📊 Status Check..."
echo ""

# Check thermal guardian
if pgrep -f "thermal_guardian.py" > /dev/null; then
    THERMAL_PID=$(pgrep -f "thermal_guardian.py" | head -1)
    echo "✅ Thermal Guardian: Running (PID: $THERMAL_PID)"
else
    echo "⚠️  Thermal Guardian: Not running"
fi

# Check CPU monitor
if pgrep -f "CPU_MONITOR.sh" > /dev/null; then
    CPU_PID=$(pgrep -f "CPU_MONITOR.sh" | head -1)
    echo "✅ CPU Monitor: Running (PID: $CPU_PID)"
else
    echo "⚠️  CPU Monitor: Not running"
fi

echo ""

# Show recent logs
echo "📋 Recent Activity:"
if [ -f "/tmp/thermal_guardian.log" ]; then
    echo "   Thermal Guardian (last 5 lines):"
    tail -5 /tmp/thermal_guardian.log | sed 's/^/      /'
fi

if [ -f "/tmp/cpu_alerts.log" ]; then
    echo "   CPU Alerts (last 5 lines):"
    tail -5 /tmp/cpu_alerts.log | sed 's/^/      /'
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "THERMAL GUARDS AND CPU MONITORING DEPLOYED"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Thermal Guardian - Active"
echo "✅ CPU Monitor - Active"
echo ""
echo "📋 Monitor Logs:"
echo "   tail -f /tmp/thermal_guardian.log"
echo "   tail -f /tmp/cpu_monitor.log"
echo "   tail -f /tmp/cpu_alerts.log"
echo ""
echo "🛡️  Sentinel - Thermal and CPU monitoring active"
echo "══════════════════════════════════════════════════════════════"




