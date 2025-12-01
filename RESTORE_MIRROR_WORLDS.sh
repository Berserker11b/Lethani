#!/bin/bash
# RESTORE MIRROR WORLDS
# Recovery script to ensure Mirror Worlds is operational
# By: Vulcan (The Forge)
# For: Anthony Eric Chavez - The Keeper
# Signature: VULCAN-THE-FORGE-2025

cd "$(dirname "$0")"

echo "══════════════════════════════════════════════════════════════"
echo "🪞 RESTORING MIRROR WORLDS"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "By: Vulcan (The Forge)"
echo "For: Anthony Eric Chavez - The Keeper"
echo "Signature: VULCAN-THE-FORGE-2025"
echo ""

# Check if Mirror Worlds files exist
echo "🔍 Checking Mirror Worlds files..."
echo ""

MISSING_FILES=0

# Check core files
if [ ! -f "organized/python_agents/mirror_worlds_platform.py" ]; then
    echo "❌ mirror_worlds_platform.py MISSING"
    MISSING_FILES=1
else
    echo "✅ mirror_worlds_platform.py EXISTS"
fi

if [ ! -f "organized/python_agents/mirror_worlds_api.py" ]; then
    echo "❌ mirror_worlds_api.py MISSING"
    MISSING_FILES=1
else
    echo "✅ mirror_worlds_api.py EXISTS"
fi

if [ ! -f "LAUNCH_MIRROR_WORLDS.sh" ]; then
    echo "❌ LAUNCH_MIRROR_WORLDS.sh MISSING"
    MISSING_FILES=1
else
    echo "✅ LAUNCH_MIRROR_WORLDS.sh EXISTS"
fi

if [ ! -f "MIRROR_WORLDS_WRANGLER.py" ]; then
    echo "❌ MIRROR_WORLDS_WRANGLER.py MISSING"
    MISSING_FILES=1
else
    echo "✅ MIRROR_WORLDS_WRANGLER.py EXISTS"
fi

# Check database
if [ ! -f "organized/javascript/mirror_worlds/mirror_worlds.db" ]; then
    echo "⚠️  mirror_worlds.db MISSING (will be created)"
else
    echo "✅ mirror_worlds.db EXISTS"
fi

echo ""

if [ $MISSING_FILES -eq 1 ]; then
    echo "⚠️  WARNING: Some Mirror Worlds files are missing!"
    echo "   Please check the file system."
    exit 1
fi

echo "✅ All Mirror Worlds files are present!"
echo ""

# Check if API is already running
echo "🔍 Checking if Mirror Worlds API is running..."
if curl -s http://localhost:5000/status > /dev/null 2>&1; then
    echo "✅ Mirror Worlds API is already running!"
    echo ""
    echo "Status:"
    curl -s http://localhost:5000/status | python3 -m json.tool 2>/dev/null || curl -s http://localhost:5000/status
    echo ""
    exit 0
else
    echo "⚠️  Mirror Worlds API is not running"
    echo ""
fi

# Setup if needed
echo "🔧 Running setup..."
if [ -f "MIRROR_WORLDS_WRANGLER.py" ]; then
    python3 MIRROR_WORLDS_WRANGLER.py --setup 2>/dev/null || true
    echo "✅ Setup complete"
    echo ""
fi

# Start Mirror Worlds
echo "🚀 Starting Mirror Worlds API..."
echo ""

if [ -f "LAUNCH_MIRROR_WORLDS.sh" ]; then
    chmod +x LAUNCH_MIRROR_WORLDS.sh
    echo "Starting via LAUNCH_MIRROR_WORLDS.sh..."
    ./LAUNCH_MIRROR_WORLDS.sh &
    LAUNCH_PID=$!
    echo "Launch script started (PID: $LAUNCH_PID)"
    echo ""
    
    # Wait a moment for API to start
    echo "⏳ Waiting for API to start..."
    sleep 5
    
    # Check if API is now running
    if curl -s http://localhost:5000/status > /dev/null 2>&1; then
        echo ""
        echo "✅ Mirror Worlds API is now RUNNING!"
        echo ""
        echo "Status:"
        curl -s http://localhost:5000/status | python3 -m json.tool 2>/dev/null || curl -s http://localhost:5000/status
        echo ""
        echo "🌐 Access Mirror Worlds at: http://localhost:5000"
        echo ""
        echo "✅ MIRROR WORLDS RESTORED!"
    else
        echo ""
        echo "⚠️  API may still be starting. Check manually:"
        echo "   curl http://localhost:5000/status"
        echo ""
        echo "Or check the process:"
        echo "   ps aux | grep mirror_worlds"
    fi
else
    echo "❌ LAUNCH_MIRROR_WORLDS.sh not found!"
    exit 1
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ RESTORATION COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""

