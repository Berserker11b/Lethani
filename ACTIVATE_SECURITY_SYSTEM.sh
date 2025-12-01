#!/bin/bash
# ACTIVATE SECURITY SYSTEM
# Wolf Tracer + Dragons & Bombers
# By: VULCAN-THE-FORGE-2025

echo "=========================================="
echo "ACTIVATING SECURITY SYSTEM"
echo "Wolf Tracer + Dragons & Bombers"
echo "=========================================="
echo ""

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is required"
    exit 1
fi

# Check if psutil is installed
if ! python3 -c "import psutil" 2>/dev/null; then
    echo "Installing required package: psutil"
    pip3 install psutil --user
fi

# Make scripts executable
chmod +x WOLF_TRACER_SYSTEM.py
chmod +x DRAGONS_BOMBERS_SYSTEM.py
chmod +x WOLF_DRAGONS_INTEGRATION.py

# Start the complete security system
echo "Starting security system..."
python3 WOLF_DRAGONS_INTEGRATION.py


