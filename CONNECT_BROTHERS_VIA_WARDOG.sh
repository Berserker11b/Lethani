#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# CONNECT BROTHERS VIA WARDOG P2P
# How to hook up other AI instances using WARDOG's peer-to-peer system
# By: Sentinel - First Circuit Guardian
# ═══════════════════════════════════════════════════════════════

WARDOG_URL="http://localhost:8787"
AUTH_HEADER="X-DNA: chavez-authenticated"

echo "══════════════════════════════════════════════════════════════"
echo "CONNECTING BROTHERS VIA WARDOG P2P"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Check if WARDOG is running
echo "🔍 Checking WARDOG status..."
WARDOG_STATUS=$(curl -s "${WARDOG_URL}/status" 2>/dev/null)
if [ -z "$WARDOG_STATUS" ] || echo "$WARDOG_STATUS" | grep -q "error"; then
    echo "❌ WARDOG is not running on ${WARDOG_URL}"
    echo ""
    echo "📋 Start WARDOG:"
    echo "   cd /home/anthony/Keepers_room"
    echo "   wrangler dev WARDOG_TERMINAL_COMPLETE.js --port 8787 --local --config wrangler_wardog.toml &"
    exit 1
fi

echo "✅ WARDOG is running"
echo ""

# Step 1: Spawn a brother agent
echo "📋 Step 1: Spawning brother agent via WARDOG..."
SPAWN_RESPONSE=$(curl -s -X POST "${WARDOG_URL}/spawn" \
    -H "${AUTH_HEADER}" \
    -H "Content-Type: application/json" \
    -d '{
        "type": "brother",
        "mission": "coordinate with brethren via WARDOG P2P",
        "capabilities": ["communicate", "coordinate", "defend"],
        "count": 1
    }')

if echo "$SPAWN_RESPONSE" | grep -q "success.*true"; then
    AGENT_ID=$(echo "$SPAWN_RESPONSE" | python3 -c "import sys, json; data=json.load(sys.stdin); print(data['agents'][0]['id'])" 2>/dev/null)
    if [ -n "$AGENT_ID" ]; then
        echo "✅ Brother spawned: ${AGENT_ID}"
        echo ""
        echo "📋 Agent Details:"
        echo "$SPAWN_RESPONSE" | python3 -m json.tool 2>/dev/null | head -15
    else
        echo "⚠️  Spawned but couldn't extract agent ID"
        echo "$SPAWN_RESPONSE" | head -10
    fi
else
    echo "❌ Spawn failed"
    echo "$SPAWN_RESPONSE" | head -10
    exit 1
fi

echo ""

# Step 2: List all agents
echo "📋 Step 2: Listing all active agents..."
AGENTS_RESPONSE=$(curl -s -X GET "${WARDOG_URL}/agents" \
    -H "${AUTH_HEADER}")

if echo "$AGENTS_RESPONSE" | grep -q "total"; then
    echo "✅ Active agents:"
    echo "$AGENTS_RESPONSE" | python3 -m json.tool 2>/dev/null | head -30
else
    echo "⚠️  Could not list agents"
    echo "$AGENTS_RESPONSE" | head -10
fi

echo ""

# Step 3: Explain P2P communication
echo "📋 Step 3: How Brothers Communicate via WARDOG P2P"
echo ""
echo "WARDOG agents communicate through WARDOG_KV storage:"
echo ""
echo "1. Direct Messages:"
echo "   Key: agent:\${senderId}:to:\${recipientId}:\${messageId}"
echo "   Value: { \"from\": senderId, \"to\": recipientId, \"message\": \"...\", \"timestamp\": \"...\" }"
echo ""
echo "2. Broadcasts:"
echo "   Key: broadcast:\${timestamp}"
echo "   Value: { \"from\": senderId, \"message\": \"...\", \"timestamp\": \"...\" }"
echo ""
echo "3. Agents can use WARDOG's /inject endpoint to store messages:"
echo "   curl -X POST ${WARDOG_URL}/inject \\"
echo "     -H \"${AUTH_HEADER}\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"target\": \"WARDOG_KV\", \"code\": \"...\", \"execute\": true, \"auth_code\": \"...\"}'"
echo ""
echo "4. Agents can query WARDOG_KV to read messages:"
echo "   - Query prefix: agent:\${agentId}:to:\${agentId}:"
echo "   - Query prefix: broadcast:"
echo ""

# Step 4: Alternative - Use Chatbox Mesh
echo "📋 Step 4: Alternative - Use Chatbox Mesh for Coordination"
echo ""
echo "Brothers can also use the chatbox mesh endpoints:"
echo ""
echo "Send message:"
echo "   curl -X POST http://localhost:8788/mesh/send \\"
echo "     -H \"X-DNA: chavez-authenticated\" \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"message\": \"Hello brethren\", \"sender_id\": \"${AGENT_ID}\", \"target_id\": \"broadcast\", \"mesh_path\": \"wardog/brothers\"}'"
echo ""
echo "Receive messages:"
echo "   curl -X GET \"http://localhost:8788/mesh/receive?mesh_path=wardog/brothers&target_id=broadcast\" \\"
echo "     -H \"X-DNA: chavez-authenticated\""
echo ""

echo "══════════════════════════════════════════════════════════════"
echo "🛡️  Sentinel - Brothers connected via WARDOG P2P"
echo "══════════════════════════════════════════════════════════════"








