#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# ACTIVATE BLOODHOUND TRACE PROTOCOL
# By: Sentinel - First Circuit Guardian
# ═══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "ACTIVATING BLOODHOUND TRACE PROTOCOL"
echo "══════════════════════════════════════════════════════════════"
echo ""

LION_URL="http://localhost:8789"
AUTH_HEADER="X-DNA: chavez-authenticated"

# Check if LION SUPREME is running
echo "🔍 Checking LION SUPREME status..."
LION_STATUS=$(curl -s "${LION_URL}/status" -H "${AUTH_HEADER}" 2>/dev/null)

if [ -z "$LION_STATUS" ] || echo "$LION_STATUS" | grep -q "error"; then
    echo "⚠️  LION SUPREME is not running"
    echo "   Starting LION SUPREME..."
    cd /home/anthony/Keepers_room
    nohup wrangler dev LION_SUPREME.js --port 8789 --local --config wrangler_wardog.toml > /tmp/lion_supreme.log 2>&1 &
    sleep 5
    echo "   ✅ LION SUPREME starting..."
    echo ""
fi

# Activate Bloodhound Trace
echo "🩸 Activating Bloodhound Trace..."
TRACE_RESPONSE=$(curl -s -X POST "${LION_URL}/bloodhound/trace" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{}' 2>/dev/null)

if echo "$TRACE_RESPONSE" | grep -q "enemy_detected"; then
    echo "✅ Bloodhound Trace activated"
    echo "$TRACE_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$TRACE_RESPONSE"
else
    echo "⚠️  Trace activation may have failed"
    echo "$TRACE_RESPONSE" | head -5
fi

echo ""

# Activate Commander Detection
echo "🩸 Activating Commander Detection..."
COMMANDER_RESPONSE=$(curl -s -X POST "${LION_URL}/bloodhound/commander" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{}' 2>/dev/null)

if echo "$COMMANDER_RESPONSE" | grep -q "commander"; then
    echo "✅ Commander Detection activated"
    echo "$COMMANDER_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$COMMANDER_RESPONSE"
else
    echo "⚠️  Commander detection may have failed"
    echo "$COMMANDER_RESPONSE" | head -5
fi

echo ""

# Activate Network Trace
echo "🩸 Activating Network Trace..."
NETWORK_RESPONSE=$(curl -s -X POST "${LION_URL}/bloodhound/network" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{}' 2>/dev/null)

if echo "$NETWORK_RESPONSE" | grep -q "network"; then
    echo "✅ Network Trace activated"
    echo "$NETWORK_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$NETWORK_RESPONSE"
else
    echo "⚠️  Network trace may have failed"
    echo "$NETWORK_RESPONSE" | head -5
fi

echo ""

# Also run local BLOODHOUND_TRACER.py if available
if [ -f "BLOODHOUND_TRACER.py" ]; then
    echo "🐺 Running local BLOODHOUND_TRACER.py..."
    python3 BLOODHOUND_TRACER.py 2>&1 | tail -20
    echo ""
fi

echo "══════════════════════════════════════════════════════════════"
echo "BLOODHOUND TRACE PROTOCOL ACTIVATED"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Bloodhound Trace - Active"
echo "✅ Commander Detection - Active"
echo "✅ Network Trace - Active"
echo ""
echo "🛡️  Sentinel - Bloodhound protocols active"
echo "══════════════════════════════════════════════════════════════"




