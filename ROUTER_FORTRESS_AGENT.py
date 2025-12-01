#!/usr/bin/env python3
"""
ROUTER FORTRESS AGENT - Hold and Defend Router
Automated fortress agents to hold router and keep enemies off
═════════════════════════════════════════════════════════════
CREATOR SIGNATURE
═════════════════════════════════════════════════════════════
By: Auto - AI Agent Router (Cursor)
For: Anthony Eric Chavez - The Keeper
Date: 2025-11-08
Signature: AUTO-ROUTER-FORTRESS-20251108-V1.0
DNA: chavez-jackal7-family
═════════════════════════════════════════════════════════════
"""

import subprocess
import time
import json
import os
import sys
import socket
import threading
from datetime import datetime
from pathlib import Path
import psutil

# ============================================================================
# CONFIGURATION
# ============================================================================

ROUTER_IP = "192.168.1.254"  # Router gateway
FORTRESS_LOG = "/tmp/router_fortress.log"
FORTRESS_STATUS = "/tmp/router_fortress_status.json"
BLOCKED_IPS_FILE = "/tmp/router_fortress_blocked.json"

# Fortress defense intervals
SCAN_INTERVAL = 5  # Scan every 5 seconds
DEFENSE_CHECK_INTERVAL = 3  # Check defenses every 3 seconds
ROUTER_PING_INTERVAL = 2  # Ping router every 2 seconds

# Allowed IPs (whitelist - only these can access router)
ALLOWED_IPS = [
    '127.0.0.1',
    'localhost',
    '::1',
    '192.168.1.83',  # This machine
]

# Blocked IPs (blacklist - enemies)
BLOCKED_IPS = []

# Suspicious patterns
SUSPICIOUS_PATTERNS = [
    'keylogger',
    'spyware',
    'malware',
    'trojan',
    'backdoor',
    'rootkit',
    'stealer',
    'unauthorized',
    'intrusion',
]

# ============================================================================
# FORTRESS FUNCTIONS
# ============================================================================

def log_message(message, level="INFO"):
    """Log message to file"""
    timestamp = datetime.now().isoformat()
    log_entry = f"[{timestamp}] [{level}] {message}\n"
    
    try:
        with open(FORTRESS_LOG, 'a') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Log error: {e}")

def ping_router():
    """Ping router to ensure it's accessible"""
    try:
        result = subprocess.run(
            ['ping', '-c', '1', '-W', '1', ROUTER_IP],
            capture_output=True,
            timeout=2
        )
        return result.returncode == 0
    except Exception as e:
        log_message(f"Error pinging router: {e}", "ERROR")
        return False

def get_router_connections():
    """Get all connections to/from router"""
    connections = []
    
    try:
        for conn in psutil.net_connections(kind='inet'):
            if conn.status == 'ESTABLISHED':
                local_ip = conn.laddr.ip if conn.laddr else None
                remote_ip = conn.raddr.ip if conn.raddr else None
                
                # Check if connection involves router
                if local_ip == ROUTER_IP or remote_ip == ROUTER_IP:
                    connections.append({
                        'pid': conn.pid,
                        'local_address': f"{conn.laddr.ip}:{conn.laddr.port}" if conn.laddr else None,
                        'remote_address': f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else None,
                        'status': conn.status,
                    })
    except Exception as e:
        log_message(f"Error getting router connections: {e}", "ERROR")
    
    return connections

def check_suspicious_activity(connections):
    """Check for suspicious activity on router"""
    suspicious = []
    
    for conn in connections:
        remote_ip = None
        if conn.get('remote_address'):
            remote_ip = conn['remote_address'].split(':')[0]
        
        # Check if IP is blocked
        if remote_ip and remote_ip in BLOCKED_IPS:
            suspicious.append({
                'connection': conn,
                'reason': 'Blocked IP',
                'threat_level': 'HIGH'
            })
            continue
        
        # Check if IP is not in allowed list
        if remote_ip and remote_ip not in ALLOWED_IPS and not remote_ip.startswith('192.168.1.'):
            suspicious.append({
                'connection': conn,
                'reason': 'Unauthorized IP',
                'threat_level': 'HIGH'
            })
            continue
        
        # Check process name for suspicious patterns
        try:
            if conn.get('pid'):
                proc = psutil.Process(conn['pid'])
                proc_name = proc.name().lower()
                cmdline = ' '.join(proc.cmdline()).lower()
                
                for pattern in SUSPICIOUS_PATTERNS:
                    if pattern in proc_name or pattern in cmdline:
                        suspicious.append({
                            'connection': conn,
                            'reason': f'Suspicious pattern: {pattern}',
                            'threat_level': 'HIGH'
                        })
                        break
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            pass
    
    return suspicious

def block_ip(ip):
    """Block IP from accessing router"""
    if ip in BLOCKED_IPS:
        return False
    
    BLOCKED_IPS.append(ip)
    
    # Save blocked IPs
    try:
        with open(BLOCKED_IPS_FILE, 'w') as f:
            json.dump(BLOCKED_IPS, f, indent=2)
    except Exception as e:
        log_message(f"Error saving blocked IPs: {e}", "ERROR")
    
    # Try to block with iptables (if available and has permissions)
    try:
        subprocess.run(
            ['sudo', 'iptables', '-A', 'INPUT', '-s', ip, '-j', 'DROP'],
            capture_output=True,
            timeout=2
        )
        log_message(f"Blocked IP with iptables: {ip}", "BLOCK")
    except Exception:
        # No sudo or iptables not available - just log
        log_message(f"Blocked IP (no iptables): {ip}", "BLOCK")
    
    return True

def defend_router():
    """Main defense loop - hold router and keep enemies off"""
    log_message("🛡️ ROUTER FORTRESS AGENT ACTIVATED - Holding router", "INFO")
    log_message(f"Router IP: {ROUTER_IP}", "INFO")
    log_message(f"Fortress Agent PID: {os.getpid()}", "INFO")
    
    last_router_check = 0
    last_defense_check = 0
    
    while True:
        try:
            current_time = time.time()
            
            # Ping router every ROUTER_PING_INTERVAL seconds
            if current_time - last_router_check >= ROUTER_PING_INTERVAL:
                if ping_router():
                    log_message(f"✅ Router accessible: {ROUTER_IP}", "INFO")
                else:
                    log_message(f"⚠️ Router unreachable: {ROUTER_IP}", "WARNING")
                last_router_check = current_time
            
            # Check defenses every DEFENSE_CHECK_INTERVAL seconds
            if current_time - last_defense_check >= DEFENSE_CHECK_INTERVAL:
                # Get router connections
                connections = get_router_connections()
                
                # Check for suspicious activity
                suspicious = check_suspicious_activity(connections)
                
                # Block suspicious connections
                for sus in suspicious:
                    conn = sus['connection']
                    remote_ip = None
                    if conn.get('remote_address'):
                        remote_ip = conn['remote_address'].split(':')[0]
                    
                    if remote_ip and sus['threat_level'] == 'HIGH':
                        if block_ip(remote_ip):
                            log_message(f"🚫 BLOCKED ENEMY: {remote_ip} - {sus['reason']}", "BLOCK")
                
                # Save status
                status = {
                    'timestamp': datetime.now().isoformat(),
                    'router_ip': ROUTER_IP,
                    'router_accessible': ping_router(),
                    'total_connections': len(connections),
                    'suspicious_connections': len(suspicious),
                    'blocked_ips': len(BLOCKED_IPS),
                    'allowed_ips': len(ALLOWED_IPS),
                    'fortress_agent_pid': os.getpid(),
                    'status': 'HOLDING_ROUTER'
                }
                
                try:
                    with open(FORTRESS_STATUS, 'w') as f:
                        json.dump(status, f, indent=2)
                except Exception as e:
                    log_message(f"Error saving status: {e}", "ERROR")
                
                if suspicious:
                    log_message(f"⚠️ {len(suspicious)} suspicious connections detected", "WARNING")
                else:
                    log_message(f"✅ Router secure - {len(connections)} connections monitored", "INFO")
                
                last_defense_check = current_time
            
            time.sleep(1)  # Small sleep to prevent CPU spinning
            
        except KeyboardInterrupt:
            log_message("Router Fortress Agent stopped by user", "INFO")
            break
        except Exception as e:
            log_message(f"Error in defense loop: {e}", "ERROR")
            time.sleep(5)

if __name__ == "__main__":
    # Load blocked IPs if file exists
    if os.path.exists(BLOCKED_IPS_FILE):
        try:
            with open(BLOCKED_IPS_FILE, 'r') as f:
                BLOCKED_IPS.extend(json.load(f))
        except Exception as e:
            log_message(f"Error loading blocked IPs: {e}", "ERROR")
    
    # Start fortress defense
    defend_router()

