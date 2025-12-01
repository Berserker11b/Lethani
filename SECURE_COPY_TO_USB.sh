#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# SECURE USB COPY - BLOCKS PROCESSES & DAEMONS
# By: VULCAN-THE-FORGE-2025
# For: Anthony Eric Chavez - The Keeper
# ═══════════════════════════════════════════════════════════════

SOURCE="/home/anthony/Keepers_room"
TARGET="/media/anthony/3526-709E"

# Default target (can be overridden)
if [ -n "$1" ]; then
    TARGET="$1"
fi

echo "══════════════════════════════════════════════════════════════"
echo "🔒 SECURE USB COPY SYSTEM"
echo "   Blocks Background Processes & Daemons"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Check if Python 3 is available
if ! command -v python3 &> /dev/null; then
    echo "❌ ERROR: Python 3 is required"
    exit 1
fi

# Check if psutil is installed
if ! python3 -c "import psutil" 2>/dev/null; then
    echo "📦 Installing required package: psutil"
    pip3 install psutil --user
fi

# Check if source exists
if [ ! -d "$SOURCE" ]; then
    echo "❌ ERROR: Source directory does not exist: $SOURCE"
    exit 1
fi

# Check if target is mounted
if [ ! -d "$TARGET" ]; then
    echo "❌ ERROR: Target USB drive not mounted: $TARGET"
    echo ""
    echo "Please:"
    echo "  1. Insert your USB drive"
    echo "  2. Wait for it to mount"
    echo "  3. Run this script again"
    echo ""
    echo "Or specify target: $0 /path/to/usb"
    exit 1
fi

# Make script executable
chmod +x SECURE_USB_COPY_SYSTEM.py

# Create target directory
TARGET_DIR="$TARGET/KEEPERS_ROOM_SECURE_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$TARGET_DIR"

echo "📁 Target directory: $TARGET_DIR"
echo ""

# Run secure copy
echo "🚀 Starting secure copy..."
echo "   Scanning for processes/daemons..."
echo ""

python3 SECURE_USB_COPY_SYSTEM.py "$SOURCE" "$TARGET_DIR" \
    --exclude "__pycache__" ".git" "node_modules" "*.pyc" "*.pyo" \
    --log "secure_usb_copy_$(date +%Y%m%d_%H%M%S).log"

EXIT_CODE=$?

echo ""
echo "══════════════════════════════════════════════════════════════"

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ SECURE COPY COMPLETE"
    echo "   Files copied to: $TARGET_DIR"
    echo "   No processes or daemons were copied"
else
    echo "❌ COPY FAILED - Check errors above"
    exit $EXIT_CODE
fi

echo "══════════════════════════════════════════════════════════════"


