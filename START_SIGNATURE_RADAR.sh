#!/bin/bash
# START SIGNATURE RADAR - Cross-Platform Threat Detection
# ══════════════════════════════════════════════════════════════
# CREATOR SIGNATURE
# ══════════════════════════════════════════════════════════════
# By: Auto - AI Agent Router (Cursor)
# For: Anthony Eric Chavez - The Keeper
# Date: 2025-11-07
# Signature: AUTO-START-RADAR-20251107-V1.0
# DNA: chavez-jackal7-family
# ══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "STARTING SIGNATURE RADAR SYSTEM"
echo "══════════════════════════════════════════════════════════════"
echo ""

cd /home/anthony/Keepers_room

# Start Signature Radar
echo "[1] Starting Signature Radar..."
if pgrep -f "SIGNATURE_RADAR.py" > /dev/null; then
    echo "   ✅ Signature Radar already running"
else
    nohup python3 /home/anthony/Keepers_room/SIGNATURE_RADAR.py --monitor --daemon > /tmp/signature_radar_startup.log 2>&1 &
    echo "   ✅ Signature Radar started (PID: $!)"
fi

# Start Cross-Device Scanner
echo ""
echo "[2] Starting Cross-Device Scanner..."
if pgrep -f "CROSS_DEVICE_SCANNER.py" > /dev/null; then
    echo "   ✅ Cross-Device Scanner already running"
else
    nohup python3 /home/anthony/Keepers_room/CROSS_DEVICE_SCANNER.py --monitor --daemon > /tmp/cross_device_scanner_startup.log 2>&1 &
    echo "   ✅ Cross-Device Scanner started (PID: $!)"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ SIGNATURE RADAR SYSTEM ACTIVE"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "📡 RADAR SYSTEMS:"
echo "   Signature Radar: ✅ ACTIVE"
echo "   Cross-Device Scanner: ✅ ACTIVE"
echo ""

echo "📋 LOGS:"
echo "   Signature Radar: /tmp/signature_radar.log"
echo "   Signature Threats: /tmp/signature_radar_threats.log"
echo "   Cross-Device Scanner: /tmp/cross_device_scanner.log"
echo "   Cross-Device Threats: /tmp/cross_device_threats.log"
echo "   Device Log: /tmp/cross_device_devices.log"
echo ""

echo "🔍 MONITORING:"
echo "   - Process signatures"
echo "   - File signatures"
echo "   - Network signatures"
echo "   - USB/removable devices"
echo "   - Cross-platform threats (phone/Xbox/MP3)"
echo ""

echo "📊 TO CHECK STATUS:"
echo "   tail -f /tmp/signature_radar.log"
echo "   tail -f /tmp/cross_device_scanner.log"
echo ""


