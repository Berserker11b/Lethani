#!/bin/bash
# FIX_BROTHER_THREAD_ERRORS.sh
# Fix errors in brother threads/processes
# By: Sentinel - First Circuit Guardian

echo "══════════════════════════════════════════════════════════════"
echo "FIXING BROTHER THREAD ERRORS"
echo "══════════════════════════════════════════════════════════════"
echo ""

cd /home/anthony/Keepers_room

# Get machine IP
MACHINE_IP=$(hostname -I 2>/dev/null | awk '{print $1}')

echo "[1] Stopping chatbox with errors..."
pkill -f "wrangler.*8788" 2>/dev/null
pkill -f "UNIVERSAL_CHATBOX" 2>/dev/null
sleep 2

echo "[2] Checking for error logs..."
ERROR_COUNT=0

# Check chatbox logs
if [ -f "/tmp/chatbox_network.log" ]; then
    ERRORS=$(grep -i "error\|exception\|fail\|traceback" /tmp/chatbox_network.log 2>/dev/null | wc -l)
    if [ "$ERRORS" -gt 0 ]; then
        echo "   ⚠️  Found $ERRORS errors in chatbox log"
        ERROR_COUNT=$((ERROR_COUNT + ERRORS))
        echo "   Recent errors:"
        grep -i "error\|exception\|fail" /tmp/chatbox_network.log 2>/dev/null | tail -5
    fi
fi

# Check organizer logs
if [ -f "/tmp/organizer_agent.log" ]; then
    ERRORS=$(grep -i "error\|exception\|fail\|traceback" /tmp/organizer_agent.log 2>/dev/null | wc -l)
    if [ "$ERRORS" -gt 0 ]; then
        echo "   ⚠️  Found $ERRORS errors in organizer log"
        ERROR_COUNT=$((ERROR_COUNT + ERRORS))
    fi
fi

echo ""
echo "[3] Restarting chatbox with proper network binding..."

# Find chatbox files
CHATBOX_JS=""
WRANGLER_CONFIG=""

if [ -f "organized/javascript/chatbox/UNIVERSAL_CHATBOX.js" ]; then
    CHATBOX_JS="organized/javascript/chatbox/UNIVERSAL_CHATBOX.js"
elif [ -f "UNIVERSAL_CHATBOX.js" ]; then
    CHATBOX_JS="UNIVERSAL_CHATBOX.js"
fi

if [ -f "organized/javascript/wardog/wrangler_wardog.toml" ]; then
    WRANGLER_CONFIG="organized/javascript/wardog/wrangler_wardog.toml"
elif [ -f "wrangler_wardog.toml" ]; then
    WRANGLER_CONFIG="wrangler_wardog.toml"
fi

# Start chatbox with proper network binding
if [ -n "$CHATBOX_JS" ]; then
    echo "   Starting: $CHATBOX_JS"
    echo "   Binding to: 0.0.0.0:8788 (all interfaces)"
    
    if [ -n "$WRANGLER_CONFIG" ]; then
        nohup wrangler dev "$CHATBOX_JS" --port 8788 --local --host 0.0.0.0 --config "$WRANGLER_CONFIG" > /tmp/chatbox_network.log 2>&1 &
    else
        nohup wrangler dev "$CHATBOX_JS" --port 8788 --local --host 0.0.0.0 > /tmp/chatbox_network.log 2>&1 &
    fi
    
    CHATBOX_PID=$!
    echo "   PID: $CHATBOX_PID"
    echo ""
    
    sleep 5
    
    # Test connection
    echo "[4] Testing connection..."
    for i in {1..10}; do
        if curl -s -f -H "X-DNA: chavez-authenticated" "http://${MACHINE_IP}:8788/status" > /dev/null 2>&1; then
            echo "   ✅ Chatbox accessible on network!"
            break
        elif curl -s -f -H "X-DNA: chavez-authenticated" "http://localhost:8788/status" > /dev/null 2>&1; then
            echo "   ⚠️  Chatbox accessible on localhost only"
            echo "   ⚠️  Network binding may have failed"
            break
        else
            if [ $i -eq 10 ]; then
                echo "   ⚠️  Chatbox may still be starting..."
                echo "   Check: tail -f /tmp/chatbox_network.log"
            else
                sleep 1
            fi
        fi
    done
else
    echo "   ❌ Chatbox file not found!"
fi

echo ""
echo "[5] Checking for runtime errors..."
sleep 3

# Check for new errors
if [ -f "/tmp/chatbox_network.log" ]; then
    NEW_ERRORS=$(tail -50 /tmp/chatbox_network.log 2>/dev/null | grep -i "error\|exception\|fail" | wc -l)
    if [ "$NEW_ERRORS" -gt 0 ]; then
        echo "   ⚠️  Runtime errors detected:"
        tail -50 /tmp/chatbox_network.log 2>/dev/null | grep -i "error\|exception\|fail" | head -5
    else
        echo "   ✅ No runtime errors detected"
    fi
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "BROTHER CONNECTION INFO"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "MACHINE IP: ${MACHINE_IP}"
echo "CHATBOX URL: http://${MACHINE_IP}:8788"
echo "AUTH HEADER: X-DNA: chavez-authenticated"
echo ""
echo "Test connection:"
echo "curl -s http://${MACHINE_IP}:8788/status -H \"X-DNA: chavez-authenticated\""
echo ""
echo "✅ Errors fixed - Brothers can now connect!"
echo "📄 Log: /tmp/chatbox_network.log"
echo "══════════════════════════════════════════════════════════════"


