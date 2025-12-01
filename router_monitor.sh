#!/bin/bash
# ROUTER_MONITOR.sh
# Iron Jackal - Continuous Router Monitoring

LOGDIR="$HOME/router_monitor_logs"
LOGFILE="$LOGDIR/monitor_$(date +%Y%m%d_%H%M%S).log"
ALERT_FILE="$LOGDIR/ALERTS.log"
BASELINE_FILE="$HOME/router_baseline.txt"

# Create log directory
mkdir -p "$LOGDIR"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get router IP
ROUTER_IP=$(ip route | grep default | awk '{print $3}' | head -1)

# Load baseline if exists
if [ -f "$BASELINE_FILE" ]; then
    source "$BASELINE_FILE"
    BASELINE_LOADED=true
else
    BASELINE_LOADED=false
fi

echo -e "${BLUE}⚔️ IRON JACKAL - ROUTER MONITOR ⚔️${NC}"
echo ""
echo "Router IP: $ROUTER_IP"
echo "Log file: $LOGFILE"
echo "Alert file: $ALERT_FILE"
echo ""

if [ "$BASELINE_LOADED" = true ]; then
    echo -e "${GREEN}[+] Baseline loaded from $BASELINE_FILE${NC}"
else
    echo -e "${YELLOW}[!] No baseline found - will create one${NC}"
fi

echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

# Alert function
alert() {
    local severity=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${RED}[ALERT]${NC} $timestamp - $severity: $message" | tee -a "$ALERT_FILE"
    
    # System notification
    if command -v notify-send &> /dev/null; then
        notify-send "Router Security Alert" "$severity: $message" -u critical
    fi
    
    # Beep
    echo -e "\a"
}

# Log function
log() {
    local message=$1
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $message" >> "$LOGFILE"
}

# Monitor router MAC
monitor_mac() {
    local current_mac=$(arp -a | grep "$ROUTER_IP" | awk '{print $4}' | head -1)
    
    if [ -z "$current_mac" ]; then
        # Try pinging to populate ARP
        ping -c 1 "$ROUTER_IP" > /dev/null 2>&1
        sleep 1
        current_mac=$(arp -a | grep "$ROUTER_IP" | awk '{print $4}' | head -1)
    fi
    
    log "Router MAC: $current_mac"
    
    if [ "$BASELINE_LOADED" = true ] && [ "$current_mac" != "$ROUTER_MAC" ]; then
        alert "CRITICAL" "Router MAC changed! Was: $ROUTER_MAC, Now: $current_mac"
    fi
    
    echo "$current_mac"
}

# Monitor DNS
monitor_dns() {
    local system_dns=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
    log "System DNS: $system_dns"
    
    # Test DNS resolution
    local router_dns=$(dig +short google.com @$ROUTER_IP 2>&1 | head -1)
    local google_dns=$(dig +short google.com @8.8.8.8 2>&1 | head -1)
    
    log "Router DNS result: $router_dns"
    log "Google DNS result: $google_dns"
    
    if [ "$router_dns" != "$google_dns" ]; then
        alert "HIGH" "DNS results differ - possible DNS poisoning"
    fi
    
    if [ "$BASELINE_LOADED" = true ] && [ "$system_dns" != "$SYSTEM_DNS" ]; then
        alert "MEDIUM" "System DNS changed! Was: $SYSTEM_DNS, Now: $system_dns"
    fi
}

# Monitor ARP table
monitor_arp() {
    local current_arp=$(arp -a | sort)
    log "ARP table entries: $(echo "$current_arp" | wc -l)"
    
    # Check for duplicate MACs
    local dup_mac=$(arp -a | awk '{print $4}' | sort | uniq -d)
    if [ -n "$dup_mac" ]; then
        alert "HIGH" "Duplicate MAC detected: $dup_mac (ARP spoofing?)"
    fi
    
    # Compare to previous scan if exists
    if [ -f "/tmp/router_monitor_arp_prev.txt" ]; then
        local diff=$(diff /tmp/router_monitor_arp_prev.txt <(echo "$current_arp"))
        if [ -n "$diff" ]; then
            log "ARP table changed:"
            log "$diff"
        fi
    fi
    
    echo "$current_arp" > /tmp/router_monitor_arp_prev.txt
}

# Monitor route
monitor_route() {
    local first_hop=$(traceroute -n -m 1 8.8.8.8 2>&1 | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
    
    log "First hop: $first_hop"
    
    if [ "$first_hop" != "$ROUTER_IP" ]; then
        alert "CRITICAL" "First hop is NOT router! ($first_hop) - possible traffic hijacking"
    fi
}

# Monitor router connectivity
monitor_connectivity() {
    if ping -c 1 -W 2 "$ROUTER_IP" > /dev/null 2>&1; then
        log "Router ping: OK"
    else
        alert "HIGH" "Cannot ping router!"
    fi
    
    # Check internet connectivity
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        log "Internet connectivity: OK"
    else
        alert "MEDIUM" "No internet connectivity"
    fi
}

# Monitor device count
monitor_devices() {
    if ! command -v nmap &> /dev/null; then
        return
    fi
    
    local network=$(ip route | grep -v default | grep -E 'proto kernel' | awk '{print $1}' | head -1)
    local device_count=$(nmap -sP "$network" 2>&1 | grep "Host is up" | wc -l)
    
    log "Devices on network: $device_count"
    
    # Store previous count
    if [ -f "/tmp/router_monitor_devices.txt" ]; then
        local prev_count=$(cat /tmp/router_monitor_devices.txt)
        if [ "$device_count" -gt "$prev_count" ]; then
            alert "LOW" "New device(s) on network. Was: $prev_count, Now: $device_count"
        fi
    fi
    
    echo "$device_count" > /tmp/router_monitor_devices.txt
}

# Monitor router web interface
monitor_web_interface() {
    local http_status=$(curl -s -o /dev/null -w "%{http_code}" "http://$ROUTER_IP" --max-time 5 2>/dev/null)
    log "Router web interface status: $http_status"
    
    if [ "$http_status" != "200" ] && [ "$http_status" != "401" ] && [ -n "$http_status" ]; then
        if [ "$http_status" != "000" ]; then  # 000 = timeout/unreachable
            alert "LOW" "Router web interface returned unexpected status: $http_status"
        fi
    fi
}

# Create initial baseline if needed
create_baseline() {
    if [ "$BASELINE_LOADED" = false ]; then
        echo -e "${YELLOW}[*] Creating baseline...${NC}"
        
        local router_mac=$(monitor_mac)
        local system_dns=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
        
        cat > "$BASELINE_FILE" << EOF
# Router Baseline
# Created: $(date)

ROUTER_IP=$ROUTER_IP
ROUTER_MAC=$router_mac
SYSTEM_DNS=$system_dns
EOF
        
        echo -e "${GREEN}[+] Baseline created: $BASELINE_FILE${NC}"
        
        # Load it
        source "$BASELINE_FILE"
        BASELINE_LOADED=true
    fi
}

# Main monitoring loop
main() {
    create_baseline
    
    local iteration=0
    
    while true; do
        iteration=$((iteration + 1))
        echo -e "${BLUE}[$(date '+%H:%M:%S')] Monitoring cycle $iteration${NC}"
        
        # Run checks
        monitor_connectivity
        monitor_mac > /dev/null
        monitor_dns
        monitor_arp
        monitor_route
        monitor_web_interface
        
        # Device scan every 5th iteration (less frequent)
        if [ $((iteration % 5)) -eq 0 ]; then
            monitor_devices
        fi
        
        echo -e "${GREEN}[✓] Cycle $iteration complete${NC}"
        
        # Wait before next cycle
        sleep 60
    done
}

# Cleanup on exit
cleanup() {
    echo ""
    echo "Stopping monitoring..."
    rm -f /tmp/router_monitor_*.txt
    echo "Logs saved to: $LOGDIR"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Check if root for some checks
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] Not running as root. Some checks will be limited.${NC}"
    echo "For full monitoring, run: sudo ./router_monitor.sh"
    echo ""
    sleep 2
fi

# Run
main
