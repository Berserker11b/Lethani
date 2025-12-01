#!/bin/bash
# ACTIVATE RECON FLYERS - Fast Threat Detection
# By: Vulcan (The Forge)
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "ACTIVATING RECON FLYERS - FAST THREAT DETECTION"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "By: Vulcan (The Forge)"
echo "For: Anthony Eric Chavez - The Keeper"
echo ""
echo "Time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 1: IMMEDIATE RECON SCAN
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 1: IMMEDIATE RECON SCAN"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🚀 Launching recon flyers for immediate scan..."
python3 RECON_FLYERS.py --quick
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 2: ACTIVATE CONTINUOUS RECON
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 2: ACTIVATING CONTINUOUS RECON"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🔄 Activating continuous reconnaissance..."
python3 RECON_FLYERS.py --continuous --interval 15 > /tmp/recon_flyers.log 2>&1 &
RECON_PID=$!
echo "   ✅ Recon flyers activated (PID: $RECON_PID)"
echo "   📊 Scanning every 15 seconds"
echo "   📝 Log: /tmp/recon_flyers.log"
echo "   ⚠️  Threat log: /tmp/recon_threats.log"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 3: CHECK FOR IMMEDIATE THREATS
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 3: CHECKING FOR IMMEDIATE THREATS"
echo "══════════════════════════════════════════════════════════════"
echo ""

sleep 2  # Give recon time to complete first scan

if [ -f "/tmp/recon_flyers_status.json" ]; then
    echo "📊 Recon Status:"
    python3 << 'PYTHON_SCRIPT'
import json
try:
    with open('/tmp/recon_flyers_status.json', 'r') as f:
        status = json.load(f)
        print(f"   Process threats: {status.get('process_threats', 0)}")
        print(f"   Network threats: {status.get('network_threats', 0)}")
        
        if status.get('threats'):
            print("\n   ⚠️  THREATS DETECTED:")
            for threat in status['threats'][:5]:
                print(f"      - PID {threat['pid']}: {threat['name']} ({threat['reason']})")
        
        if status.get('suspicious_connections'):
            print("\n   ⚠️  SUSPICIOUS CONNECTIONS:")
            for conn in status['suspicious_connections'][:5]:
                print(f"      - {conn['remote_address']} ({conn['reason']})")
except Exception as e:
    print(f"   Error reading status: {e}")
PYTHON_SCRIPT
else
    echo "   ⚠️  Status file not found yet"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 4: RAPID RESPONSE PROTOCOL
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 4: RAPID RESPONSE PROTOCOL"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "⚡ Activating rapid response..."
echo "   ✅ Recon flyers: ACTIVE"
echo "   ✅ Threat detection: ACTIVE"
echo "   ✅ Continuous monitoring: ACTIVE"
echo ""

# Check if threats were found
if [ -f "/tmp/recon_threats.log" ]; then
    THREAT_COUNT=$(wc -l < /tmp/recon_threats.log 2>/dev/null || echo "0")
    if [ "$THREAT_COUNT" -gt 0 ]; then
        echo "   ⚠️  WARNING: $THREAT_COUNT threats detected!"
        echo "   📋 Review: /tmp/recon_threats.log"
        echo ""
        echo "   🚨 RECOMMENDED ACTIONS:"
        echo "      1. Review threat log: cat /tmp/recon_threats.log"
        echo "      2. Check recon status: python3 -c \"from RECON_FLYERS import get_recon_status; import json; print(json.dumps(get_recon_status(), indent=2))\""
        echo "      3. Activate Monster Hunter: python3 MONSTER_HUNTER.py"
        echo "      4. Activate CPU Compressor: ./CPU_COMPRESSOR.sh"
    else
        echo "   ✅ No immediate threats detected"
    fi
else
    echo "   ✅ No threats detected yet"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "RECON FLYERS ACTIVATED"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "✅ Recon Flyers:"
echo "   - Status: ACTIVE (PID: $RECON_PID)"
echo "   - Scan interval: 15 seconds"
echo "   - Log: /tmp/recon_flyers.log"
echo "   - Threat log: /tmp/recon_threats.log"
echo "   - Status file: /tmp/recon_flyers_status.json"
echo ""

echo "📊 Check Status:"
echo "   python3 -c \"from RECON_FLYERS import get_recon_status; import json; print(json.dumps(get_recon_status(), indent=2))\""
echo ""

echo "🛑 Stop Recon:"
echo "   kill $RECON_PID"
echo ""

echo "══════════════════════════════════════════════════════════════"
echo ""







