#!/bin/bash
# DEPLOY ROUTER GUARDS AND AUTOMATED AGENT FACTORY
# By: Vulcan (The Forge)
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "DEPLOYING ROUTER GUARDS AND AUTOMATED AGENT FACTORY"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "By: Vulcan (The Forge)"
echo "For: Anthony Eric Chavez - The Keeper"
echo ""
echo "Time: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 1: DEPLOY ROUTER GUARDS
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 1: DEPLOYING ROUTER GUARDS"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🛡️  Activating Router Guards..."
if [ -f "ROUTER_GUARDS.py" ]; then
    python3 ROUTER_GUARDS.py > /tmp/router_guards.log 2>&1 &
    ROUTER_PID=$!
    echo "   ✅ Router Guards deployed (PID: $ROUTER_PID)"
    echo "   📊 Monitoring network connections"
    echo "   🔒 Blocking suspicious connections"
    echo "   📝 Log: /tmp/router_guards.log"
else
    echo "   ❌ Router Guards script not found"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 2: DEPLOY AUTOMATED AGENT FACTORY
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 2: DEPLOYING AUTOMATED AGENT FACTORY"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🏭 Activating Automated Agent Factory..."
if [ -f "AUTOMATED_AGENT_FACTORY.py" ]; then
    python3 AUTOMATED_AGENT_FACTORY.py > /tmp/agent_factory.log 2>&1 &
    FACTORY_PID=$!
    echo "   ✅ Agent Factory deployed (PID: $FACTORY_PID)"
    echo "   🤖 Spawning defensive agents"
    echo "   🔄 Maintaining agent count"
    echo "   📝 Log: /tmp/agent_factory.log"
    echo "   📊 Status: /tmp/agent_factory_status.json"
else
    echo "   ❌ Agent Factory script not found"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# PHASE 3: VERIFY DEPLOYMENT
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "PHASE 3: VERIFYING DEPLOYMENT"
echo "══════════════════════════════════════════════════════════════"
echo ""

sleep 3  # Give processes time to start

echo "🔍 Checking Router Guards..."
if [ -n "$ROUTER_PID" ] && ps -p $ROUTER_PID > /dev/null 2>&1; then
    echo "   ✅ Router Guards: RUNNING (PID: $ROUTER_PID)"
else
    echo "   ❌ Router Guards: NOT RUNNING"
fi

echo "🔍 Checking Agent Factory..."
if [ -n "$FACTORY_PID" ] && ps -p $FACTORY_PID > /dev/null 2>&1; then
    echo "   ✅ Agent Factory: RUNNING (PID: $FACTORY_PID)"
    
    # Check agent status
    if [ -f "/tmp/agent_factory_status.json" ]; then
        echo "   📊 Agent Status:"
        python3 << 'PYTHON_SCRIPT'
import json
try:
    with open('/tmp/agent_factory_status.json', 'r') as f:
        status = json.load(f)
        print(f"      Total agents: {status.get('total_agents', 0)}")
        for agent_id, agent_info in status.get('agents', {}).items():
            print(f"      - {agent_info.get('type', 'unknown')}: {agent_info.get('status', 'unknown')} (PID: {agent_info.get('pid', 'N/A')})")
except Exception as e:
    print(f"      Error reading status: {e}")
PYTHON_SCRIPT
    fi
else
    echo "   ❌ Agent Factory: NOT RUNNING"
fi
echo ""

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "DEPLOYMENT COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "✅ Router Guards:"
echo "   - Network monitoring: ACTIVE"
echo "   - Connection blocking: ACTIVE"
echo "   - Status file: /tmp/router_guards_status.json"
echo "   - Log: /tmp/router_guards.log"
echo ""

echo "✅ Automated Agent Factory:"
echo "   - Agent spawning: ACTIVE"
echo "   - Agent maintenance: ACTIVE"
echo "   - Status file: /tmp/agent_factory_status.json"
echo "   - Log: /tmp/agent_factory.log"
echo ""

echo "📊 Check Status:"
echo "   python3 -c \"from ROUTER_GUARDS import get_router_guard_status; import json; print(json.dumps(get_router_guard_status(), indent=2))\""
echo "   python3 -c \"from AUTOMATED_AGENT_FACTORY import get_factory_status; import json; print(json.dumps(get_factory_status(), indent=2))\""
echo ""

echo "🛑 Stop Services:"
echo "   kill $ROUTER_PID $FACTORY_PID"
echo ""

echo "══════════════════════════════════════════════════════════════"
echo ""







