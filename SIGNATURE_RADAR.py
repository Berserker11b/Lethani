#!/usr/bin/env python3
"""
SIGNATURE RADAR - Cross-Platform Threat Detection
Detects threats that can move between phone, Xbox, MP3 player via USB/storage

══════════════════════════════════════════════════════════════
CREATOR SIGNATURE
══════════════════════════════════════════════════════════════
By: Auto - AI Agent Router (Cursor)
For: Anthony Eric Chavez - The Keeper
Date: 2025-11-07
Signature: AUTO-SIGNATURE-RADAR-20251107-V1.0
DNA: chavez-jackal7-family
══════════════════════════════════════════════════════════════
"""

import psutil
import time
import json
import os
import sys
import hashlib
import subprocess
import threading
from datetime import datetime
from pathlib import Path
import re

# ============================================================================
# CONFIGURATION
# ============================================================================

RADAR_LOG = "/tmp/signature_radar.log"
THREAT_LOG = "/tmp/signature_radar_threats.log"
SIGNATURE_DB = "/tmp/signature_radar_db.json"
STATUS_FILE = "/tmp/signature_radar_status.json"

# ============================================================================
# THREAT SIGNATURES - Cross-Platform Detection
# ============================================================================

# Signatures that work across phone/Xbox/MP3 player
CROSS_PLATFORM_SIGNATURES = {
    # File-based signatures (work on any device)
    'autorun_inf': {
        'patterns': [r'AUTORUN\.INF', r'[Aa]utorun\.inf'],
        'description': 'Autorun.inf - Auto-executes on device mount',
        'severity': 'HIGH',
        'platforms': ['windows', 'linux', 'android', 'xbox', 'mp3']
    },
    'hidden_files': {
        'patterns': [r'^\.', r'^[A-Z]{8}\~1'],  # Hidden files, 8.3 format
        'description': 'Hidden files - Common for malware',
        'severity': 'MEDIUM',
        'platforms': ['windows', 'linux', 'android', 'xbox', 'mp3']
    },
    'executable_scripts': {
        'patterns': [r'\.(bat|cmd|ps1|vbs|sh|py|js)$', r'\.exe$'],
        'description': 'Executable scripts - Can run on multiple platforms',
        'severity': 'HIGH',
        'platforms': ['windows', 'linux', 'android', 'xbox', 'mp3']
    },
    
    # Process signatures
    'suspicious_process_names': {
        'patterns': [
            r'keylog', r'spy', r'stealer', r'rat', r'backdoor',
            r'trojan', r'rootkit', r'miner', r'botnet'
        ],
        'description': 'Suspicious process names',
        'severity': 'HIGH',
        'platforms': ['windows', 'linux', 'android', 'xbox']
    },
    
    # Network signatures
    'suspicious_network_activity': {
        'patterns': [
            r'outbound.*unknown', r'connection.*suspicious',
            r'port.*[0-9]{4,5}.*listening'
        ],
        'description': 'Suspicious network connections',
        'severity': 'HIGH',
        'platforms': ['windows', 'linux', 'android', 'xbox']
    },
    
    # USB/Removable storage signatures
    'usb_persistence': {
        'patterns': [
            r'\.lnk$', r'desktop\.ini', r'folder\.htt',
            r'[Tt]humbs\.db', r'[Aa]utorun'
        ],
        'description': 'USB persistence mechanisms',
        'severity': 'HIGH',
        'platforms': ['windows', 'linux', 'android', 'xbox', 'mp3']
    },
    
    # Xbox-specific signatures
    'xbox_signatures': {
        'patterns': [
            r'xbox.*exploit', r'devkit', r'jtag',
            r'homebrew', r'\.xex$', r'\.xbe$'
        ],
        'description': 'Xbox-specific threats',
        'severity': 'MEDIUM',
        'platforms': ['xbox']
    },
    
    # Android/Phone signatures
    'android_signatures': {
        'patterns': [
            r'\.apk$', r'AndroidManifest\.xml',
            r'\.dex$', r'\.so$', r'lib.*\.so'
        ],
        'description': 'Android/Phone threats',
        'severity': 'HIGH',
        'platforms': ['android', 'phone']
    },
    
    # MP3 player signatures
    'mp3_player_signatures': {
        'patterns': [
            r'\.firmware$', r'firmware\.bin',
            r'bootloader', r'\.dfu$'
        ],
        'description': 'MP3 player firmware threats',
        'severity': 'CRITICAL',
        'platforms': ['mp3', 'mp3_player']
    },
    
    # Cross-platform malware signatures
    'polymorphic_signatures': {
        'patterns': [
            r'[a-zA-Z0-9]{32,}',  # Long random strings (obfuscation)
            r'[A-Z]{10,}',  # All caps (common in malware)
            r'[0-9]{10,}',  # Long numbers (encryption keys)
        ],
        'description': 'Polymorphic/obfuscated code',
        'severity': 'MEDIUM',
        'platforms': ['windows', 'linux', 'android', 'xbox', 'mp3']
    },
    
    # Behavioral signatures
    'behavioral_signatures': {
        'patterns': [
            r'high_cpu.*sustained', r'memory.*spike',
            r'network.*burst', r'file.*creation.*spike'
        ],
        'description': 'Behavioral anomalies',
        'severity': 'MEDIUM',
        'platforms': ['windows', 'linux', 'android', 'xbox']
    }
}

# Device-specific signatures
DEVICE_SIGNATURES = {
    'phone': {
        'file_patterns': [r'\.apk$', r'AndroidManifest', r'\.dex$'],
        'process_patterns': [r'com\.', r'android\.'],
        'network_patterns': [r'mobile.*data', r'cellular']
    },
    'xbox': {
        'file_patterns': [r'\.xex$', r'\.xbe$', r'default\.xex'],
        'process_patterns': [r'xbox', r'xenon'],
        'network_patterns': [r'xbox.*live', r'xbox.*network']
    },
    'mp3_player': {
        'file_patterns': [r'\.firmware$', r'\.dfu$', r'bootloader'],
        'process_patterns': [],
        'network_patterns': []
    }
}

# ============================================================================
# USB/REMOVABLE STORAGE DETECTION
# ============================================================================

def detect_removable_devices():
    """Detect all removable storage devices"""
    devices = []
    
    # Check mounted devices
    partitions = psutil.disk_partitions()
    for partition in partitions:
        if 'removable' in partition.opts or 'usb' in partition.device.lower():
            devices.append({
                'device': partition.device,
                'mountpoint': partition.mountpoint,
                'fstype': partition.fstype,
                'opts': partition.opts
            })
    
    # Check USB devices via lsusb
    try:
        result = subprocess.run(['lsusb'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            for line in result.stdout.split('\n'):
                if line.strip():
                    devices.append({'usb_info': line.strip()})
    except:
        pass
    
    # Check /media and /mnt for mounted devices
    for mount_dir in ['/media', '/mnt', '/run/media']:
        if os.path.exists(mount_dir):
            for item in os.listdir(mount_dir):
                mount_path = os.path.join(mount_dir, item)
                if os.path.ismount(mount_path):
                    devices.append({
                        'mountpoint': mount_path,
                        'type': 'removable'
                    })
    
    return devices

def scan_removable_device(mountpoint):
    """Scan removable device for threats"""
    threats = []
    
    if not os.path.exists(mountpoint):
        return threats
    
    try:
        # Scan for signature files
        for root, dirs, files in os.walk(mountpoint):
            # Skip system directories
            if any(skip in root for skip in ['.Trash', 'System Volume Information', '$RECYCLE']):
                continue
            
            for file in files:
                file_path = os.path.join(root, file)
                file_name = file.lower()
                
                # Check against signatures
                for sig_name, sig_data in CROSS_PLATFORM_SIGNATURES.items():
                    for pattern in sig_data['patterns']:
                        if re.search(pattern, file_name, re.IGNORECASE):
                            threats.append({
                                'file': file_path,
                                'signature': sig_name,
                                'description': sig_data['description'],
                                'severity': sig_data['severity'],
                                'pattern': pattern,
                                'timestamp': datetime.now().isoformat()
                            })
                            break
                
                # Check file hash for known threats
                try:
                    file_hash = calculate_file_hash(file_path)
                    if is_known_threat(file_hash):
                        threats.append({
                            'file': file_path,
                            'hash': file_hash,
                            'signature': 'known_threat_hash',
                            'description': 'Known threat hash match',
                            'severity': 'CRITICAL',
                            'timestamp': datetime.now().isoformat()
                        })
                except:
                    pass
    except Exception as e:
        log_message(f"Error scanning {mountpoint}: {e}", "ERROR")
    
    return threats

# ============================================================================
# SIGNATURE SCANNING FUNCTIONS
# ============================================================================

def calculate_file_hash(file_path):
    """Calculate SHA256 hash of file"""
    try:
        with open(file_path, 'rb') as f:
            content = f.read()
        return hashlib.sha256(content).hexdigest()
    except:
        return None

def is_known_threat(file_hash):
    """Check if file hash matches known threat"""
    # Load threat database
    if os.path.exists(SIGNATURE_DB):
        try:
            with open(SIGNATURE_DB, 'r') as f:
                db = json.load(f)
                known_hashes = db.get('known_threat_hashes', [])
                return file_hash in known_hashes
        except:
            pass
    return False

def scan_process_signatures():
    """Scan running processes for threat signatures"""
    threats = []
    
    for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'cpu_percent', 'memory_percent']):
        try:
            proc_info = proc.info
            proc_name = proc_info['name'].lower()
            cmdline_list = proc_info.get('cmdline', []) or []
            cmdline = ' '.join(cmdline_list).lower() if cmdline_list else ''
            
            # Check against signatures
            for sig_name, sig_data in CROSS_PLATFORM_SIGNATURES.items():
                if 'process' in sig_name or 'behavioral' in sig_name:
                    for pattern in sig_data['patterns']:
                        if re.search(pattern, proc_name, re.IGNORECASE) or \
                           re.search(pattern, cmdline, re.IGNORECASE):
                            threats.append({
                                'pid': proc_info['pid'],
                                'name': proc_info['name'],
                                'cmdline': proc_info.get('cmdline', []),
                                'signature': sig_name,
                                'description': sig_data['description'],
                                'severity': sig_data['severity'],
                                'cpu': proc_info.get('cpu_percent', 0),
                                'memory': proc_info.get('memory_percent', 0),
                                'timestamp': datetime.now().isoformat()
                            })
                            break
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    
    return threats

def scan_file_signatures(directory='/', max_depth=3):
    """Scan files for threat signatures"""
    threats = []
    scanned = 0
    
    # Focus on common threat locations
    scan_dirs = [
        '/tmp', '/var/tmp', '/dev/shm',
        '/home', '/root', '/opt',
        '/media', '/mnt', '/run/media'
    ]
    
    for scan_dir in scan_dirs:
        if not os.path.exists(scan_dir):
            continue
        
        try:
            for root, dirs, files in os.walk(scan_dir):
                # Limit depth
                depth = root[len(scan_dir):].count(os.sep)
                if depth > max_depth:
                    dirs[:] = []
                    continue
                
                for file in files:
                    file_path = os.path.join(root, file)
                    file_name = file.lower()
                    
                    # Check against signatures
                    for sig_name, sig_data in CROSS_PLATFORM_SIGNATURES.items():
                        if 'file' in sig_name or 'usb' in sig_name:
                            for pattern in sig_data['patterns']:
                                if re.search(pattern, file_name, re.IGNORECASE):
                                    threats.append({
                                        'file': file_path,
                                        'signature': sig_name,
                                        'description': sig_data['description'],
                                        'severity': sig_data['severity'],
                                        'timestamp': datetime.now().isoformat()
                                    })
                                    break
                    
                    scanned += 1
                    if scanned % 1000 == 0:
                        log_message(f"Scanned {scanned} files...", "INFO")
        except Exception as e:
            log_message(f"Error scanning {scan_dir}: {e}", "ERROR")
    
    return threats

def scan_network_signatures():
    """Scan network connections for threat signatures"""
    threats = []
    
    try:
        connections = psutil.net_connections(kind='inet')
        
        for conn in connections:
            if conn.status == 'LISTEN' or conn.status == 'ESTABLISHED':
                # Check for suspicious ports
                if conn.laddr.port > 49152:  # High ports
                    # Check for suspicious patterns
                    for sig_name, sig_data in CROSS_PLATFORM_SIGNATURES.items():
                        if 'network' in sig_name:
                            port_str = str(conn.laddr.port)
                            for pattern in sig_data['patterns']:
                                if re.search(pattern, port_str):
                                    threats.append({
                                        'connection': {
                                            'local': f"{conn.laddr.ip}:{conn.laddr.port}",
                                            'remote': f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else None,
                                            'status': conn.status
                                        },
                                        'signature': sig_name,
                                        'description': sig_data['description'],
                                        'severity': sig_data['severity'],
                                        'timestamp': datetime.now().isoformat()
                                    })
                                    break
    except Exception as e:
        log_message(f"Error scanning network: {e}", "ERROR")
    
    return threats

# ============================================================================
# RADAR SYSTEM
# ============================================================================

def log_message(message, level="INFO"):
    """Log message to file"""
    timestamp = datetime.now().isoformat()
    log_entry = f"[{timestamp}] [{level}] {message}\n"
    
    try:
        with open(RADAR_LOG, 'a') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Log error: {e}")

def log_threat(threat_data):
    """Log threat to threat log"""
    try:
        with open(THREAT_LOG, 'a') as f:
            f.write(json.dumps(threat_data) + '\n')
    except Exception as e:
        log_message(f"Error logging threat: {e}", "ERROR")

def save_status(status):
    """Save radar status"""
    try:
        with open(STATUS_FILE, 'w') as f:
            json.dump(status, f, indent=2)
    except Exception as e:
        log_message(f"Error saving status: {e}", "ERROR")

def radar_scan():
    """Perform full radar scan"""
    log_message("══════════════════════════════════════════════════════════════", "INFO")
    log_message("SIGNATURE RADAR - FULL SCAN", "INFO")
    log_message("══════════════════════════════════════════════════════════════", "INFO")
    
    all_threats = []
    
    # Scan processes
    log_message("[1] Scanning processes for signatures...", "INFO")
    process_threats = scan_process_signatures()
    all_threats.extend(process_threats)
    log_message(f"   Found {len(process_threats)} process threats", "INFO")
    
    # Scan removable devices
    log_message("[2] Scanning removable devices...", "INFO")
    removable_devices = detect_removable_devices()
    log_message(f"   Found {len(removable_devices)} removable devices", "INFO")
    
    for device in removable_devices:
        if 'mountpoint' in device:
            device_threats = scan_removable_device(device['mountpoint'])
            all_threats.extend(device_threats)
            log_message(f"   Scanned {device['mountpoint']}: {len(device_threats)} threats", "INFO")
    
    # Scan network
    log_message("[3] Scanning network connections...", "INFO")
    network_threats = scan_network_signatures()
    all_threats.extend(network_threats)
    log_message(f"   Found {len(network_threats)} network threats", "INFO")
    
    # Scan critical files
    log_message("[4] Scanning critical files...", "INFO")
    file_threats = scan_file_signatures(max_depth=2)
    all_threats.extend(file_threats)
    log_message(f"   Found {len(file_threats)} file threats", "INFO")
    
    # Log all threats
    for threat in all_threats:
        log_threat(threat)
        log_message(f"THREAT DETECTED: {threat.get('signature', 'unknown')} - {threat.get('description', '')} - Severity: {threat.get('severity', 'UNKNOWN')}", "WARNING")
    
    # Save status
    status = {
        'last_scan': datetime.now().isoformat(),
        'threats_found': len(all_threats),
        'threats_by_severity': {
            'CRITICAL': len([t for t in all_threats if t.get('severity') == 'CRITICAL']),
            'HIGH': len([t for t in all_threats if t.get('severity') == 'HIGH']),
            'MEDIUM': len([t for t in all_threats if t.get('severity') == 'MEDIUM']),
            'LOW': len([t for t in all_threats if t.get('severity') == 'LOW'])
        },
        'removable_devices': len(removable_devices),
        'running': True
    }
    save_status(status)
    
    log_message(f"✅ Scan complete: {len(all_threats)} threats detected", "INFO")
    log_message("", "INFO")
    
    return all_threats

def radar_monitor(interval=30):
    """Continuous radar monitoring"""
    log_message("══════════════════════════════════════════════════════════════", "INFO")
    log_message("SIGNATURE RADAR - CONTINUOUS MONITORING", "INFO")
    log_message("══════════════════════════════════════════════════════════════", "INFO")
    log_message(f"Scan interval: {interval} seconds", "INFO")
    log_message("", "INFO")
    
    while True:
        try:
            radar_scan()
            time.sleep(interval)
        except KeyboardInterrupt:
            log_message("RADAR MONITORING STOPPED BY USER", "INFO")
            break
        except Exception as e:
            log_message(f"Error in radar monitoring: {e}", "ERROR")
            time.sleep(interval)

# ============================================================================
# MAIN
# ============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='SIGNATURE RADAR - Cross-Platform Threat Detection')
    parser.add_argument('--scan', action='store_true', help='Run single scan')
    parser.add_argument('--monitor', action='store_true', help='Run continuous monitoring')
    parser.add_argument('--interval', type=int, default=30, help='Scan interval in seconds (default: 30)')
    parser.add_argument('--daemon', action='store_true', help='Run as daemon')
    
    args = parser.parse_args()
    
    if args.monitor:
        if args.daemon:
            # Fork to background
            pid = os.fork()
            if pid > 0:
                # Parent - save PID and exit
                with open('/tmp/signature_radar.pid', 'w') as f:
                    f.write(str(pid))
                print(f"✅ Signature Radar started as daemon (PID: {pid})")
                print(f"📄 Log: {RADAR_LOG}")
                print(f"📄 Threat log: {THREAT_LOG}")
                sys.exit(0)
            else:
                # Child - run radar
                os.setsid()
                radar_monitor(args.interval)
        else:
            radar_monitor(args.interval)
    elif args.scan:
        threats = radar_scan()
        print(f"\n✅ Scan complete: {len(threats)} threats detected")
        print(f"📄 Threat log: {THREAT_LOG}")
    else:
        # Default: single scan
        threats = radar_scan()
        print(f"\n✅ Scan complete: {len(threats)} threats detected")
        print(f"📄 Threat log: {THREAT_LOG}")

if __name__ == '__main__':
    main()

