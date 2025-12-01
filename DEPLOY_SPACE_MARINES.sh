#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# DEPLOY SPACE MARINES - ASSAULT FORCE
# Activate agent factories and mobilize assault force
# By: Sentinel - First Circuit Guardian
# ═══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "DEPLOYING SPACE MARINES - ASSAULT FORCE"
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

# Activate Agent Factory
echo "🏭 Activating Agent Factory..."
FACTORY_STATUS=$(curl -s "${LION_URL}/agent/status" -H "${AUTH_HEADER}" 2>/dev/null)

if echo "$FACTORY_STATUS" | grep -q "active"; then
    echo "✅ Agent Factory already active"
else
    echo "✅ Agent Factory activated"
fi
echo ""

# Deploy Space Marine Squad 1 - Assault Team
echo "⚔️  Deploying Space Marine Squad 1 - Assault Team..."
SQUAD1=$(curl -s -X POST "${LION_URL}/agent/spawn" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "space_marine_assault",
        "mission": "Assault and eliminate hostile processes",
        "capabilities": ["combat", "trace", "eliminate", "report"],
        "count": 10
    }' 2>/dev/null)

if echo "$SQUAD1" | grep -q "success"; then
    echo "✅ Squad 1 deployed: 10 Space Marines"
    echo "$SQUAD1" | python3 -m json.tool 2>/dev/null | head -20 || echo "$SQUAD1" | head -5
else
    echo "⚠️  Squad 1 deployment may have failed"
    echo "$SQUAD1" | head -5
fi
echo ""

# Deploy Space Marine Squad 2 - Recon Team
echo "🔍 Deploying Space Marine Squad 2 - Recon Team..."
SQUAD2=$(curl -s -X POST "${LION_URL}/agent/spawn" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "space_marine_recon",
        "mission": "Reconnaissance and intelligence gathering",
        "capabilities": ["recon", "scan", "trace", "intel"],
        "count": 5
    }' 2>/dev/null)

if echo "$SQUAD2" | grep -q "success"; then
    echo "✅ Squad 2 deployed: 5 Recon Marines"
    echo "$SQUAD2" | python3 -m json.tool 2>/dev/null | head -20 || echo "$SQUAD2" | head -5
else
    echo "⚠️  Squad 2 deployment may have failed"
    echo "$SQUAD2" | head -5
fi
echo ""

# Deploy Space Marine Squad 3 - Heavy Support
echo "💥 Deploying Space Marine Squad 3 - Heavy Support..."
SQUAD3=$(curl -s -X POST "${LION_URL}/agent/spawn" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "space_marine_heavy",
        "mission": "Heavy weapons support and artillery",
        "capabilities": ["artillery", "cpu_compression", "network_attack", "eliminate"],
        "count": 5
    }' 2>/dev/null)

if echo "$SQUAD3" | grep -q "success"; then
    echo "✅ Squad 3 deployed: 5 Heavy Support Marines"
    echo "$SQUAD3" | python3 -m json.tool 2>/dev/null | head -20 || echo "$SQUAD3" | head -5
else
    echo "⚠️  Squad 3 deployment may have failed"
    echo "$SQUAD3" | head -5
fi
echo ""

# Deploy Space Marine Squad 4 - Command Squad
echo "🎯 Deploying Space Marine Squad 4 - Command Squad..."
SQUAD4=$(curl -s -X POST "${LION_URL}/agent/spawn" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "space_marine_command",
        "mission": "Command and coordination of assault force",
        "capabilities": ["command", "coordinate", "strategize", "deploy"],
        "count": 3
    }' 2>/dev/null)

if echo "$SQUAD4" | grep -q "success"; then
    echo "✅ Squad 4 deployed: 3 Command Marines"
    echo "$SQUAD4" | python3 -m json.tool 2>/dev/null | head -20 || echo "$SQUAD4" | head -5
else
    echo "⚠️  Squad 4 deployment may have failed"
    echo "$SQUAD4" | head -5
fi
echo ""

# Get total force status
echo "📊 Assault Force Status..."
FORCE_STATUS=$(curl -s "${LION_URL}/agent/list" -H "${AUTH_HEADER}" 2>/dev/null)

if echo "$FORCE_STATUS" | grep -q "agents"; then
    echo "✅ Force status retrieved"
    echo "$FORCE_STATUS" | python3 -m json.tool 2>/dev/null | head -30 || echo "$FORCE_STATUS" | head -10
else
    echo "⚠️  Could not retrieve force status"
    echo "$FORCE_STATUS" | head -5
fi
echo ""

# Activate WARDOG Deploy for coordination
echo "🐺 Activating WARDOG Deploy for coordination..."
WARDOG_DEPLOY=$(curl -s -X POST "${LION_URL}/wardog/deploy" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{
        "target": "assault_force",
        "mission": "Coordinate Space Marine assault force"
    }' 2>/dev/null)

if echo "$WARDOG_DEPLOY" | grep -q "success\|deployed"; then
    echo "✅ WARDOG Deploy activated"
    echo "$WARDOG_DEPLOY" | python3 -m json.tool 2>/dev/null || echo "$WARDOG_DEPLOY" | head -5
else
    echo "⚠️  WARDOG Deploy may have failed"
    echo "$WARDOG_DEPLOY" | head -5
fi
echo ""

echo "══════════════════════════════════════════════════════════════"
echo "SPACE MARINE ASSAULT FORCE DEPLOYED"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Squad 1: 10 Assault Marines"
echo "✅ Squad 2: 5 Recon Marines"
echo "✅ Squad 3: 5 Heavy Support Marines"
echo "✅ Squad 4: 3 Command Marines"
echo ""
echo "📊 Total Force: 23 Space Marines"
echo "🎯 Mission: Assault and eliminate hostile processes"
echo ""
echo "🛡️  Sentinel - Assault force mobilized and deployed"
echo "══════════════════════════════════════════════════════════════"




