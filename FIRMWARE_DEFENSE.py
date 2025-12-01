#!/usr/bin/env python3
"""
FIRMWARE DEFENSE - Protection Against Off-State Attacks
Defends against firmware-level persistence that survives power-off
By: Sentinel - First Circuit Guardian
For: The Keeper
"""
import subprocess
import os
import json
from datetime import datetime
from pathlib import Path

DEFENSE_LOG = "/tmp/firmware_defense.log"
THREAT_LOG = "/tmp/firmware_threats.log"

def log_defense(action, details):
    """Log defense actions"""
    timestamp = datetime.now().isoformat()
    entry = {
        'timestamp': timestamp,
        'action': action,
        'details': details
    }
    with open(DEFENSE_LOG, 'a') as f:
        f.write(json.dumps(entry) + '\n')

def log_threat(threat_type, details):
    """Log detected threats"""
    timestamp = datetime.now().isoformat()
    entry = {
        'timestamp': timestamp,
        'threat_type': threat_type,
        'details': details
    }
    with open(THREAT_LOG, 'a') as f:
        f.write(json.dumps(entry) + '\n')
    print(f"⚠️  THREAT DETECTED: {threat_type}")

def check_uefi_boot():
    """Check UEFI boot configuration for tampering"""
    threats = []
    try:
        # Check if UEFI is enabled
        result = subprocess.run(
            ['ls', '/sys/firmware/efi'],
            capture_output=True,
            timeout=2
        )
        if result.returncode == 0:
            # Check boot entries
            result = subprocess.run(
                ['efibootmgr', '-v'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                boot_entries = result.stdout
                # Look for suspicious boot entries
                if 'unknown' in boot_entries.lower() or 'malicious' in boot_entries.lower():
                    threats.append('Suspicious UEFI boot entry detected')
                    log_threat('UEFI_BOOT_TAMPERING', boot_entries)
        else:
            # BIOS mode - check bootloader
            if os.path.exists('/boot/grub/grub.cfg'):
                with open('/boot/grub/grub.cfg', 'r') as f:
                    grub_cfg = f.read()
                    if 'initrd' in grub_cfg and 'quiet' not in grub_cfg:
                        # Check for suspicious initrd entries
                        if 'backdoor' in grub_cfg.lower() or 'malicious' in grub_cfg.lower():
                            threats.append('Suspicious GRUB configuration')
                            log_threat('GRUB_TAMPERING', grub_cfg[:500])
    except Exception as e:
        log_defense('UEFI_CHECK_ERROR', str(e))
    
    return threats

def check_nvram():
    """Check NVRAM for persistence mechanisms"""
    threats = []
    try:
        # Check for UEFI variables
        if os.path.exists('/sys/firmware/efi/efivars'):
            result = subprocess.run(
                ['ls', '/sys/firmware/efi/efivars'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                vars_list = result.stdout.split('\n')
                # Look for suspicious variables
                for var in vars_list:
                    if var and ('boot' in var.lower() or 'persist' in var.lower()):
                        # Check if it's a known suspicious variable
                        if 'unknown' in var.lower() or len(var) > 100:
                            threats.append(f'Suspicious NVRAM variable: {var}')
                            log_threat('NVRAM_PERSISTENCE', var)
    except Exception as e:
        log_defense('NVRAM_CHECK_ERROR', str(e))
    
    return threats

def check_bootloader():
    """Check bootloader for tampering"""
    threats = []
    try:
        # Check GRUB configuration
        if os.path.exists('/boot/grub/grub.cfg'):
            # Get file hash
            result = subprocess.run(
                ['sha256sum', '/boot/grub/grub.cfg'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                current_hash = result.stdout.split()[0]
                # Store hash for comparison (first run)
                hash_file = Path('/tmp/grub_cfg_hash.txt')
                if hash_file.exists():
                    stored_hash = hash_file.read_text().strip()
                    if current_hash != stored_hash:
                        threats.append('GRUB configuration modified')
                        log_threat('BOOTLOADER_TAMPERING', f'Hash changed: {stored_hash} -> {current_hash}')
                else:
                    hash_file.write_text(current_hash)
        
        # Check for multiple bootloaders
        bootloaders = []
        if os.path.exists('/boot/grub'):
            bootloaders.append('GRUB')
        if os.path.exists('/boot/efi'):
            bootloaders.append('UEFI')
        if len(bootloaders) > 2:
            threats.append(f'Multiple bootloaders detected: {bootloaders}')
            log_threat('MULTIPLE_BOOTLOADERS', str(bootloaders))
    except Exception as e:
        log_defense('BOOTLOADER_CHECK_ERROR', str(e))
    
    return threats

def check_wake_on_lan():
    """Check Wake-on-LAN configuration"""
    threats = []
    try:
        # Check network interfaces for WoL
        result = subprocess.run(
            ['ip', 'link', 'show'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            interfaces = []
            for line in result.stdout.split('\n'):
                if ': ' in line and 'state' in line:
                    iface = line.split(':')[1].split()[0]
                    interfaces.append(iface)
            
            for iface in interfaces:
                # Check ethtool for WoL
                result = subprocess.run(
                    ['ethtool', iface],
                    capture_output=True,
                    text=True,
                    timeout=5
                )
                if result.returncode == 0:
                    if 'Wake-on: g' in result.stdout or 'Wake-on: d' in result.stdout:
                        threats.append(f'Wake-on-LAN enabled on {iface}')
                        log_threat('WAKE_ON_LAN', f'Interface: {iface}')
    except Exception as e:
        log_defense('WOL_CHECK_ERROR', str(e))
    
    return threats

def check_firmware_modules():
    """Check for suspicious firmware modules"""
    threats = []
    try:
        # Check loaded kernel modules
        result = subprocess.run(
            ['lsmod'],
            capture_output=True,
            text=True,
            timeout=5
        )
        if result.returncode == 0:
            suspicious_modules = ['backdoor', 'malicious', 'persist', 'stealth']
            for line in result.stdout.split('\n'):
                for module in suspicious_modules:
                    if module in line.lower():
                        threats.append(f'Suspicious kernel module: {line}')
                        log_threat('SUSPICIOUS_MODULE', line)
    except Exception as e:
        log_defense('MODULE_CHECK_ERROR', str(e))
    
    return threats

def check_bios_settings():
    """Check BIOS/UEFI settings for persistence"""
    threats = []
    try:
        # Check for BIOS/UEFI access
        if os.path.exists('/sys/firmware/efi'):
            # Check for secure boot status
            result = subprocess.run(
                ['mokutil', '--sb-state'],
                capture_output=True,
                text=True,
                timeout=5
            )
            if result.returncode == 0:
                if 'disabled' in result.stdout.lower():
                    threats.append('Secure Boot is disabled - vulnerable to bootkit')
                    log_threat('SECURE_BOOT_DISABLED', result.stdout)
    except Exception as e:
        log_defense('BIOS_CHECK_ERROR', str(e))
    
    return threats

def create_defense_shield():
    """Create defense shield against firmware attacks"""
    print("🛡️  Creating firmware defense shield...")
    
    # Create monitoring script
    shield_script = """#!/bin/bash
# FIRMWARE DEFENSE SHIELD - Persistent Monitoring
# By: Sentinel - First Circuit Guardian

DEFENSE_DIR="/tmp/firmware_defense"
mkdir -p "$DEFENSE_DIR"

# Monitor bootloader changes
while true; do
    if [ -f /boot/grub/grub.cfg ]; then
        CURRENT_HASH=$(sha256sum /boot/grub/grub.cfg | awk '{print $1}')
        STORED_HASH=$(cat "$DEFENSE_DIR/grub_hash.txt" 2>/dev/null || echo "")
        
        if [ -n "$STORED_HASH" ] && [ "$CURRENT_HASH" != "$STORED_HASH" ]; then
            echo "[$(date)] ⚠️  BOOTLOADER TAMPERING DETECTED" >> "$DEFENSE_DIR/alerts.log"
            echo "$CURRENT_HASH" > "$DEFENSE_DIR/grub_hash.txt"
        elif [ -z "$STORED_HASH" ]; then
            echo "$CURRENT_HASH" > "$DEFENSE_DIR/grub_hash.txt"
        fi
    fi
    
    sleep 60
done
"""
    
    shield_path = Path('/tmp/firmware_defense_shield.sh')
    shield_path.write_text(shield_script)
    shield_path.chmod(0o755)
    
    log_defense('SHIELD_CREATED', str(shield_path))
    print(f"✅ Defense shield created: {shield_path}")
    
    return shield_path

def main():
    """Main firmware defense"""
    print("🛡️  FIRMWARE DEFENSE - Protection Against Off-State Attacks")
    print("=" * 60)
    
    all_threats = []
    
    print("\n🔍 Checking UEFI/BIOS boot configuration...")
    threats = check_uefi_boot()
    all_threats.extend(threats)
    
    print("🔍 Checking NVRAM for persistence...")
    threats = check_nvram()
    all_threats.extend(threats)
    
    print("🔍 Checking bootloader integrity...")
    threats = check_bootloader()
    all_threats.extend(threats)
    
    print("🔍 Checking Wake-on-LAN configuration...")
    threats = check_wake_on_lan()
    all_threats.extend(threats)
    
    print("🔍 Checking firmware modules...")
    threats = check_firmware_modules()
    all_threats.extend(threats)
    
    print("🔍 Checking BIOS/UEFI settings...")
    threats = check_bios_settings()
    all_threats.extend(threats)
    
    print("\n" + "=" * 60)
    if all_threats:
        print(f"⚠️  FOUND {len(all_threats)} POTENTIAL THREATS:")
        for i, threat in enumerate(all_threats, 1):
            print(f"   {i}. {threat}")
    else:
        print("✅ No immediate firmware-level threats detected")
    
    print("\n🛡️  Creating defense shield...")
    shield_path = create_defense_shield()
    
    print(f"\n✅ Defense complete. Logs:")
    print(f"   Defense log: {DEFENSE_LOG}")
    print(f"   Threat log: {THREAT_LOG}")
    print(f"\n🛡️  Sentinel - Firmware defense active")
    print("=" * 60)

if __name__ == "__main__":
    main()









