#!/bin/bash
# ROUTER_SCANNER.sh
# Iron Jackal - Router Compromise Detection

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ROUTER_IP=""
ROUTER_MAC=""
EXPECTED_DNS=""
LOGFILE="$HOME/router_scan_$(date +%Y%m%d_%H%M%S).log"

echo -e "${BLUE}⚔️ IRON JACKAL - ROUTER COMPROMISE SCANNER ⚔️${NC}"
echo ""
echo "Log file: $LOGFILE"
echo ""

# Function to log and display
log() {
    echo -e "$1" | tee -a "$LOGFILE"
}

# Get router IP
get_router_ip() {
    log "${BLUE}[*] Detecting router IP...${NC}"
    
    ROUTER_IP=$(ip route | grep default | awk '{print $3}' | head -1)
    
    if [ -z "$ROUTER_IP" ]; then
        log "${RED}[!] Could not detect router IP${NC}"
        read -p "Enter router IP manually (e.g., 192.168.1.1): " ROUTER_IP
    fi
    
    log "${GREEN}[+] Router IP: $ROUTER_IP${NC}"
}

# Get router MAC
get_router_mac() {
    log "${BLUE}[*] Getting router MAC address...${NC}"
    
    ROUTER_MAC=$(arp -a | grep "$ROUTER_IP" | awk '{print $4}' | head -1)
    
    if [ -z "$ROUTER_MAC" ]; then
        log "${YELLOW}[!] Could not get router MAC - try pinging first${NC}"
        ping -c 3 "$ROUTER_IP" > /dev/null 2>&1
        sleep 2
        ROUTER_MAC=$(arp -a | grep "$ROUTER_IP" | awk '{print $4}' | head -1)
    fi
    
    log "${GREEN}[+] Router MAC: $ROUTER_MAC${NC}"
}

# Check DNS configuration
check_dns() {
    log ""
    log "${BLUE}[*] Checking DNS configuration...${NC}"
    
    # Get system DNS
    SYSTEM_DNS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | head -1)
    log "[*] System DNS: $SYSTEM_DNS"
    
    # Test DNS response
    log "[*] Testing DNS resolution..."
    
    DNS_RESULT=$(dig +short google.com @$ROUTER_IP 2>&1)
    if [ $? -eq 0 ]; then
        log "${GREEN}[+] DNS resolution working${NC}"
        log "[*] DNS result: $DNS_RESULT"
    else
        log "${RED}[!] DNS resolution failed!${NC}"
    fi
    
    # Test against Google DNS for comparison
    GOOGLE_DNS=$(dig +short google.com @8.8.8.8 2>&1)
    log "[*] Google DNS result: $GOOGLE_DNS"
    
    if [ "$DNS_RESULT" != "$GOOGLE_DNS" ]; then
        log "${YELLOW}[!] DNS results differ - possible DNS poisoning${NC}"
    else
        log "${GREEN}[+] DNS results match${NC}"
    fi
    
    # DNS leak test
    log "[*] Checking for DNS leaks..."
    DNS_SERVERS=$(dig +short google.com | wc -l)
    log "[*] Number of DNS servers responding: $DNS_SERVERS"
}

# Check for ARP spoofing
check_arp() {
    log ""
    log "${BLUE}[*] Checking for ARP spoofing...${NC}"
    
    # Get all ARP entries
    log "[*] Current ARP table:"
    arp -a | tee -a "$LOGFILE"
    
    # Check for duplicate MACs
    DUPLICATE_MAC=$(arp -a | awk '{print $4}' | sort | uniq -d)
    if [ -n "$DUPLICATE_MAC" ]; then
        log "${RED}[!] ALERT: Duplicate MAC addresses detected!${NC}"
        log "${RED}    This could indicate ARP spoofing attack${NC}"
        log "${RED}    MAC: $DUPLICATE_MAC${NC}"
    else
        log "${GREEN}[+] No duplicate MACs detected${NC}"
    fi
    
    # Monitor for ARP changes
    log "[*] Monitoring ARP table for 30 seconds..."
    arp -a > /tmp/arp_before.txt
    sleep 30
    arp -a > /tmp/arp_after.txt
    
    DIFF=$(diff /tmp/arp_before.txt /tmp/arp_after.txt)
    if [ -n "$DIFF" ]; then
        log "${YELLOW}[!] ARP table changed during monitoring:${NC}"
        log "$DIFF"
    else
        log "${GREEN}[+] ARP table stable${NC}"
    fi
}

# Scan router ports
scan_router_ports() {
    log ""
    log "${BLUE}[*] Scanning router ports...${NC}"
    
    if ! command -v nmap &> /dev/null; then
        log "${YELLOW}[!] nmap not installed - skipping port scan${NC}"
        log "[*] Install with: sudo apt install nmap"
        return
    fi
    
    log "[*] Running nmap scan on $ROUTER_IP..."
    nmap -sV -p- "$ROUTER_IP" 2>&1 | tee -a "$LOGFILE"
    
    # Check for suspicious ports
    SUSPICIOUS_PORTS="22 23 8080 8443 8888"
    for port in $SUSPICIOUS_PORTS; do
        if nmap -p $port "$ROUTER_IP" | grep -q "open"; then
            log "${YELLOW}[!] Suspicious port $port is open${NC}"
        fi
    done
}

# Trace route to external host
check_route() {
    log ""
    log "${BLUE}[*] Checking route to external host...${NC}"
    
    log "[*] Traceroute to 8.8.8.8:"
    traceroute -n -m 5 8.8.8.8 2>&1 | tee -a "$LOGFILE"
    
    # First hop should be router
    FIRST_HOP=$(traceroute -n -m 1 8.8.8.8 2>&1 | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
    
    if [ "$FIRST_HOP" = "$ROUTER_IP" ]; then
        log "${GREEN}[+] First hop is router - route looks normal${NC}"
    else
        log "${RED}[!] First hop is NOT router: $FIRST_HOP${NC}"
        log "${RED}[!] This could indicate traffic hijacking${NC}"
    fi
}

# Check connected devices
check_devices() {
    log ""
    log "${BLUE}[*] Scanning for devices on network...${NC}"
    
    if ! command -v nmap &> /dev/null; then
        log "${YELLOW}[!] nmap not installed - skipping device scan${NC}"
        return
    fi
    
    # Detect network
    NETWORK=$(ip route | grep -v default | grep -E 'proto kernel' | awk '{print $1}' | head -1)
    log "[*] Scanning network: $NETWORK"
    
    nmap -sP "$NETWORK" 2>&1 | tee -a "$LOGFILE"
    
    DEVICE_COUNT=$(nmap -sP "$NETWORK" 2>&1 | grep "Host is up" | wc -l)
    log "[*] Devices found: $DEVICE_COUNT"
    log "${YELLOW}[!] Review device list above for unknown devices${NC}"
}

# Check for traffic to router
check_router_traffic() {
    log ""
    log "${BLUE}[*] Monitoring traffic to/from router (10 seconds)...${NC}"
    
    if [ "$EUID" -ne 0 ]; then
        log "${YELLOW}[!] Not root - cannot capture packets${NC}"
        log "[*] Run with sudo for packet capture"
        return
    fi
    
    # Get active interface
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    log "[*] Capturing on interface: $INTERFACE"
    
    timeout 10 tcpdump -i "$INTERFACE" host "$ROUTER_IP" -n 2>&1 | tee -a "$LOGFILE"
    
    log "${YELLOW}[!] Review traffic above for suspicious connections${NC}"
}

# Test for common router exploits
test_vulnerabilities() {
    log ""
    log "${BLUE}[*] Testing for common vulnerabilities...${NC}"
    
    # Test for default credentials
    log "[*] Checking if web interface is accessible..."
    
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://$ROUTER_IP" 2>/dev/null)
    if [ "$HTTP_STATUS" = "200" ] || [ "$HTTP_STATUS" = "401" ]; then
        log "${YELLOW}[!] Router web interface is accessible${NC}"
        log "[*] HTTP Status: $HTTP_STATUS"
        log "[*] Try accessing: http://$ROUTER_IP"
        log "[*] Check if default credentials work (admin/admin, admin/password)"
    else
        log "[*] Router web interface not accessible or redirecting"
    fi
    
    # Check for UPnP
    log "[*] Checking for UPnP..."
    if command -v nmap &> /dev/null; then
        UPNP=$(nmap -sU -p 1900 "$ROUTER_IP" 2>&1 | grep -i "open")
        if [ -n "$UPNP" ]; then
            log "${YELLOW}[!] UPnP appears to be enabled - security risk${NC}"
        else
            log "${GREEN}[+] UPnP not detected${NC}"
        fi
    fi
}

# Generate report
generate_report() {
    log ""
    log "${BLUE}═══════════════════════════════════════════${NC}"
    log "${BLUE}SCAN SUMMARY${NC}"
    log "${BLUE}═══════════════════════════════════════════${NC}"
    log ""
    log "Router IP: $ROUTER_IP"
    log "Router MAC: $ROUTER_MAC"
    log "Scan Date: $(date)"
    log ""
    log "${YELLOW}RECOMMENDATIONS:${NC}"
    log ""
    log "1. Review the full log file: $LOGFILE"
    log "2. Document the router MAC for future comparison"
    log "3. If suspicious activity found:"
    log "   - Switch to mobile hotspot immediately"
    log "   - Factory reset router"
    log "   - Update firmware"
    log "   - Or replace router entirely"
    log "4. Enable VPN on all devices"
    log "5. Use encrypted DNS (DoH/DoT)"
    log "6. Run this scan weekly to detect changes"
    log ""
    log "${BLUE}═══════════════════════════════════════════${NC}"
}

# Save router baseline
save_baseline() {
    log ""
    log "${BLUE}[*] Saving router baseline...${NC}"
    
    BASELINE_FILE="$HOME/router_baseline.txt"
    
    cat > "$BASELINE_FILE" << EOF
# Router Baseline
# Created: $(date)

ROUTER_IP=$ROUTER_IP
ROUTER_MAC=$ROUTER_MAC
SYSTEM_DNS=$SYSTEM_DNS

# ARP Table:
$(arp -a)

# Connected Devices:
$(nmap -sP $(ip route | grep -v default | grep -E 'proto kernel' | awk '{print $1}' | head -1) 2>&1 | grep "Nmap scan report")

EOF

    log "${GREEN}[+] Baseline saved to: $BASELINE_FILE${NC}"
    log "[*] Use this to compare future scans"
}

# Main execution
main() {
    get_router_ip
    get_router_mac
    check_dns
    check_arp
    check_route
    test_vulnerabilities
    
    # Ask if want to do intensive scans
    log ""
    read -p "Run intensive scans? (port scan, device scan, traffic capture) [y/N]: " INTENSIVE
    
    if [ "$INTENSIVE" = "y" ] || [ "$INTENSIVE" = "Y" ]; then
        scan_router_ports
        check_devices
        check_router_traffic
    fi
    
    generate_report
    
    # Ask if want to save baseline
    log ""
    read -p "Save router configuration as baseline for future comparison? [y/N]: " SAVE
    
    if [ "$SAVE" = "y" ] || [ "$SAVE" = "Y" ]; then
        save_baseline
    fi
    
    log ""
    log "${GREEN}⚔️ Scan complete. Review log file: $LOGFILE${NC}"
}

# Run
main
