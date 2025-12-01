#!/bin/bash
# 🚌 BOARD THE MIRROR WORLDS BUS
# Quick launcher to play in Mirror Worlds

echo "🚌 Boarding Mirror Worlds Bus..."
echo ""

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    exit 1
fi

# Check if requests is installed
if ! python3 -c "import requests" 2>/dev/null; then
    echo "📦 Installing requests library..."
    pip3 install requests --quiet
fi

# Run the bus
cd "$(dirname "$0")"
python3 MIRROR_WORLDS_BUS.py




