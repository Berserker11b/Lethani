#!/usr/bin/env python3
"""
CROSS-DEVICE SCANNER - Detects threats that move between phone/Xbox/MP3 player
Monitors USB/removable storage for cross-platform threats

══════════════════════════════════════════════════════════════
CREATOR SIGNATURE
══════════════════════════════════════════════════════════════
By: Auto - AI Agent Router (Cursor)
For: Anthony Eric Chavez - The Keeper
Date: 2025-11-07
Signature: AUTO-CROSS-DEVICE-SCANNER-20251107-V1.0
DNA: chavez-jackal7-family
══════════════════════════════════════════════════════════════
"""

import os
import sys
import time
import json
import hashlib
import subprocess
import threading
from datetime import datetime
from pathlib import Path
import re

# ============================================================================
# CONFIGURATION
# ============================================================================

SCANNER_LOG = "/tmp/cross_device_scanner.log"
DEVICE_LOG = "/tmp/cross_device_devices.log"
THREAT_LOG = "/tmp/cross_device_threats.log"

# ============================================================================
# CROSS-DEVICE THREAT SIGNATURES
# ============================================================================

# Signatures that work across phone/Xbox/MP3 player
CROSS_DEVICE_SIGNATURES = {
    # Autorun mechanisms (work on Windows, some Linux, Xbox)
    'autorun': {
        'files': ['autorun.inf', 'autorun.ini', 'desktop.ini', 'folder.htt'],
        'description': 'Autorun mechanism - Auto-executes on device mount',
        'severity': 'CRITICAL',
        'devices': ['phone', 'xbox', 'mp3', 'usb']
    },
    
    # Executable files that can run on multiple platforms
    'multi_platform_executables': {
        'files': ['.exe', '.bat', '.cmd', '.ps1', '.sh', '.py', '.js'],
        'description': 'Executable files - Can run on multiple platforms',
        'severity': 'HIGH',
        'devices': ['phone', 'xbox', 'mp3', 'usb']
    },
    
    # Hidden/system files
    'hidden_files': {
        'patterns': [r'^\.', r'^[A-Z]{8}~1', r'System Volume Information', r'\$RECYCLE'],
        'description': 'Hidden/system files - Common for malware persistence',
        'severity': 'MEDIUM',
        'devices': ['phone', 'xbox', 'mp3', 'usb']
    },
    
    # Xbox-specific files
    'xbox_files': {
        'files': ['.xex', '.xbe', 'default.xex', 'launch.ini'],
        'description': 'Xbox executable files',
        'severity': 'HIGH',
        'devices': ['xbox']
    },
    
    # Android/Phone files
    'android_files': {
        'files': ['.apk', 'AndroidManifest.xml', '.dex', '.so'],
        'description': 'Android application files',
        'severity': 'HIGH',
        'devices': ['phone', 'android']
    },
    
    # MP3 player firmware
    'mp3_firmware': {
        'files': ['.firmware', 'firmware.bin', '.dfu', 'bootloader.bin'],
        'description': 'MP3 player firmware - Can brick device',
        'severity': 'CRITICAL',
        'devices': ['mp3', 'mp3_player']
    },
    
    # Script files that can execute
    'script_files': {
        'files': ['.vbs', '.js', '.jse', '.wsf', '.hta', '.scr'],
        'description': 'Script files - Can execute on multiple platforms',
        'severity': 'HIGH',
        'devices': ['phone', 'xbox', 'mp3', 'usb']
    },
    
    # Link/shortcut files (can hide executables)
    'link_files': {
        'files': ['.lnk', '.url', '.pif'],
        'description': 'Link/shortcut files - Can hide executables',
        'severity': 'MEDIUM',
        'devices': ['phone', 'xbox', 'mp3', 'usb']
    },
    
    # Archive files (can contain threats)
    'archive_files': {
        'files': ['.zip', '.rar', '.7z', '.tar', '.gz'],
        'description': 'Archive files - Can contain hidden threats',
        'severity': 'MEDIUM',
        'devices': ['phone', 'xbox', 'mp3', 'usb']
    }
}

# ============================================================================
# DEVICE DETECTION
# ============================================================================

def detect_usb_devices():
    """Detect all USB/removable devices"""
    devices = []
    
    # Check mounted devices
    try:
        result = subprocess.run(['lsblk', '-o', 'NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE'], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            for line in result.stdout.split('\n')[1:]:  # Skip header
                if line.strip():
                    parts = line.split()
                    if len(parts) >= 4:
                        device_name = parts[0]
                        device_type = parts[2] if len(parts) > 2 else ''
                        mountpoint = parts[3] if len(parts) > 3 else ''
                        
                        # Check if removable
                        if 'disk' in device_type or mountpoint.startswith('/media') or mountpoint.startswith('/mnt'):
                            devices.append({
                                'name': device_name,
                                'type': device_type,
                                'mountpoint': mountpoint,
                                'detected_at': datetime.now().isoformat()
                            })
    except:
        pass
    
    # Check /media and /mnt
    for mount_dir in ['/media', '/mnt', '/run/media']:
        if os.path.exists(mount_dir):
            for item in os.listdir(mount_dir):
                mount_path = os.path.join(mount_dir, item)
                if os.path.ismount(mount_path):
                    devices.append({
                        'name': item,
                        'mountpoint': mount_path,
                        'type': 'removable',
                        'detected_at': datetime.now().isoformat()
                    })
    
    # Check USB devices via lsusb
    try:
        result = subprocess.run(['lsusb'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            for line in result.stdout.split('\n'):
                if line.strip():
                    # Extract device info
                    match = re.search(r'ID ([0-9a-f]{4}):([0-9a-f]{4})', line)
                    if match:
                        devices.append({
                            'usb_id': f"{match.group(1)}:{match.group(2)}",
                            'description': line.strip(),
                            'detected_at': datetime.now().isoformat()
                        })
    except:
        pass
    
    return devices

def identify_device_type(mountpoint):
    """Identify device type (phone, Xbox, MP3 player, etc.)"""
    if not mountpoint or not os.path.exists(mountpoint):
        return 'unknown'
    
    # Check for device-specific files/directories
    try:
        contents = os.listdir(mountpoint)
        contents_lower = [c.lower() for c in contents]
        
        # Xbox indicators
        if any('xbox' in c for c in contents_lower) or \
           any(c.endswith('.xex') or c.endswith('.xbe') for c in contents_lower):
            return 'xbox'
        
        # Android/Phone indicators
        if any('android' in c for c in contents_lower) or \
           any(c.endswith('.apk') for c in contents_lower) or \
           'DCIM' in contents or 'Pictures' in contents:
            return 'phone'
        
        # MP3 player indicators
        if any('music' in c for c in contents_lower) or \
           any('mp3' in c for c in contents_lower) or \
           any(c.endswith('.firmware') for c in contents_lower):
            return 'mp3'
        
        # Generic USB storage
        return 'usb'
    except:
        return 'unknown'

# ============================================================================
# THREAT SCANNING
# ============================================================================

def scan_device_for_threats(mountpoint, device_type='unknown'):
    """Scan device for cross-platform threats"""
    threats = []
    
    if not os.path.exists(mountpoint):
        return threats
    
    log_message(f"Scanning device: {mountpoint} (Type: {device_type})")
    
    try:
        # Scan files
        for root, dirs, files in os.walk(mountpoint):
            # Skip system directories
            skip_dirs = ['.Trash', 'System Volume Information', '$RECYCLE', '.Spotlight-V100']
            dirs[:] = [d for d in dirs if d not in skip_dirs]
            
            for file in files:
                file_path = os.path.join(root, file)
                file_name = file.lower()
                
                # Check against signatures
                for sig_name, sig_data in CROSS_DEVICE_SIGNATURES.items():
                    # Check if signature applies to this device type
                    if device_type not in sig_data.get('devices', []) and 'usb' not in sig_data.get('devices', []):
                        continue
                    
                    # Check file extensions
                    if 'files' in sig_data:
                        for pattern in sig_data['files']:
                            if file_name.endswith(pattern.lower()) or pattern.lower() in file_name:
                                threats.append({
                                    'file': file_path,
                                    'signature': sig_name,
                                    'description': sig_data['description'],
                                    'severity': sig_data['severity'],
                                    'device_type': device_type,
                                    'pattern': pattern,
                                    'timestamp': datetime.now().isoformat()
                                })
                                break
                    
                    # Check patterns
                    if 'patterns' in sig_data:
                        for pattern in sig_data['patterns']:
                            if re.search(pattern, file_name, re.IGNORECASE) or \
                               re.search(pattern, file_path, re.IGNORECASE):
                                threats.append({
                                    'file': file_path,
                                    'signature': sig_name,
                                    'description': sig_data['description'],
                                    'severity': sig_data['severity'],
                                    'device_type': device_type,
                                    'pattern': pattern,
                                    'timestamp': datetime.now().isoformat()
                                })
                                break
                
                # Check file hash for known threats
                try:
                    if os.path.getsize(file_path) < 100 * 1024 * 1024:  # Skip files > 100MB
                        file_hash = calculate_file_hash(file_path)
                        if file_hash and is_known_threat(file_hash):
                            threats.append({
                                'file': file_path,
                                'hash': file_hash,
                                'signature': 'known_threat_hash',
                                'description': 'Known threat hash match',
                                'severity': 'CRITICAL',
                                'device_type': device_type,
                                'timestamp': datetime.now().isoformat()
                            })
                except:
                    pass
    except Exception as e:
        log_message(f"Error scanning {mountpoint}: {e}", "ERROR")
    
    return threats

def calculate_file_hash(file_path):
    """Calculate SHA256 hash of file"""
    try:
        with open(file_path, 'rb') as f:
            content = f.read(1024 * 1024)  # Read first 1MB for speed
        return hashlib.sha256(content).hexdigest()
    except:
        return None

def is_known_threat(file_hash):
    """Check if file hash matches known threat"""
    # This would check against a threat database
    # For now, return False
    return False

# ============================================================================
# MONITORING
# ============================================================================

def log_message(message, level="INFO"):
    """Log message to file"""
    timestamp = datetime.now().isoformat()
    log_entry = f"[{timestamp}] [{level}] {message}\n"
    
    try:
        with open(SCANNER_LOG, 'a') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Log error: {e}")

def log_device(device_data):
    """Log device detection"""
    try:
        with open(DEVICE_LOG, 'a') as f:
            f.write(json.dumps(device_data) + '\n')
    except Exception as e:
        log_message(f"Error logging device: {e}", "ERROR")

def log_threat(threat_data):
    """Log threat detection"""
    try:
        with open(THREAT_LOG, 'a') as f:
            f.write(json.dumps(threat_data) + '\n')
    except Exception as e:
        log_message(f"Error logging threat: {e}", "ERROR")

def monitor_devices(interval=10):
    """Monitor for new devices and scan them"""
    log_message("══════════════════════════════════════════════════════════════", "INFO")
    log_message("CROSS-DEVICE SCANNER - DEVICE MONITORING", "INFO")
    log_message("══════════════════════════════════════════════════════════════", "INFO")
    log_message(f"Scan interval: {interval} seconds", "INFO")
    log_message("", "INFO")
    
    known_devices = set()
    
    while True:
        try:
            # Detect devices
            devices = detect_usb_devices()
            
            # Check for new devices
            for device in devices:
                device_id = device.get('mountpoint') or device.get('name') or device.get('usb_id')
                
                if device_id and device_id not in known_devices:
                    log_message(f"🔍 NEW DEVICE DETECTED: {device_id}", "WARNING")
                    log_device(device)
                    known_devices.add(device_id)
                    
                    # Identify device type
                    mountpoint = device.get('mountpoint')
                    if mountpoint:
                        device_type = identify_device_type(mountpoint)
                        log_message(f"   Device type: {device_type}", "INFO")
                        
                        # Scan for threats
                        threats = scan_device_for_threats(mountpoint, device_type)
                        
                        if threats:
                            log_message(f"   ⚠️  {len(threats)} THREATS DETECTED!", "WARNING")
                            for threat in threats:
                                log_threat(threat)
                                log_message(f"      THREAT: {threat['signature']} - {threat['description']} - Severity: {threat['severity']}", "WARNING")
                        else:
                            log_message(f"   ✅ No threats detected", "INFO")
            
            time.sleep(interval)
        except KeyboardInterrupt:
            log_message("DEVICE MONITORING STOPPED BY USER", "INFO")
            break
        except Exception as e:
            log_message(f"Error in device monitoring: {e}", "ERROR")
            time.sleep(interval)

# ============================================================================
# MAIN
# ============================================================================

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='CROSS-DEVICE SCANNER - Detects threats on phone/Xbox/MP3 player')
    parser.add_argument('--scan', action='store_true', help='Run single scan of all devices')
    parser.add_argument('--monitor', action='store_true', help='Monitor for new devices')
    parser.add_argument('--interval', type=int, default=10, help='Monitor interval in seconds (default: 10)')
    parser.add_argument('--daemon', action='store_true', help='Run as daemon')
    
    args = parser.parse_args()
    
    if args.monitor:
        if args.daemon:
            # Fork to background
            pid = os.fork()
            if pid > 0:
                # Parent - save PID and exit
                with open('/tmp/cross_device_scanner.pid', 'w') as f:
                    f.write(str(pid))
                print(f"✅ Cross-Device Scanner started as daemon (PID: {pid})")
                print(f"📄 Log: {SCANNER_LOG}")
                print(f"📄 Device log: {DEVICE_LOG}")
                print(f"📄 Threat log: {THREAT_LOG}")
                sys.exit(0)
            else:
                # Child - run scanner
                os.setsid()
                monitor_devices(args.interval)
        else:
            monitor_devices(args.interval)
    elif args.scan:
        log_message("Running single scan of all devices...", "INFO")
        devices = detect_usb_devices()
        log_message(f"Found {len(devices)} devices", "INFO")
        
        all_threats = []
        for device in devices:
            mountpoint = device.get('mountpoint')
            if mountpoint:
                device_type = identify_device_type(mountpoint)
                threats = scan_device_for_threats(mountpoint, device_type)
                all_threats.extend(threats)
                log_message(f"Scanned {mountpoint}: {len(threats)} threats", "INFO")
        
        print(f"\n✅ Scan complete: {len(all_threats)} threats detected")
        print(f"📄 Threat log: {THREAT_LOG}")
    else:
        # Default: monitor
        monitor_devices(args.interval)

if __name__ == '__main__':
    main()


