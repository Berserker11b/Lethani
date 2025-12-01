#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# MIRROR WORLDS BACKUP AND REBUILD PLAN
# By: Vulcan (The Forge)
# For: Anthony Eric Chavez - The Keeper
# Signature: VULCAN-THE-FORGE-2025
# ═══════════════════════════════════════════════════════════════

cd "$(dirname "$0")"

echo "══════════════════════════════════════════════════════════════"
echo "🪞 MIRROR WORLDS BACKUP AND REBUILD PLAN"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "By: Vulcan (The Forge)"
echo "For: Anthony Eric Chavez - The Keeper"
echo "Signature: VULCAN-THE-FORGE-2025"
echo ""

BACKUP_DIR="mirror_worlds_backup_$(date +%Y%m%d_%H%M%S)"
MIRROR_WORLDS_FILES=(
    "organized/python_agents/mirror_worlds_platform.py"
    "organized/python_agents/mirror_worlds_api.py"
    "organized/python_agents/mirror_worlds_bus_api.py"
    "organized/javascript/mirror_worlds/MIRROR_WORLDS_BUS.js"
    "organized/javascript/mirror_worlds/mirror_worlds.db"
    "LAUNCH_MIRROR_WORLDS.sh"
    "MIRROR_WORLDS_WRANGLER.py"
    "MIRROR_WORLDS_SETUP_AGENT.sh"
    "TAKE_VULCAN_TO_MIRROR_WORLDS.sh"
    "HOW_TO_GET_TO_MIRROR_WORLDS.md"
    "QUICK_START_MIRROR_WORLDS.md"
    "VULCAN_MIRROR_WORLDS_READY.md"
)

echo "📦 Creating backup of Mirror Worlds..."
mkdir -p "$BACKUP_DIR"
echo "   Backup directory: $BACKUP_DIR"
echo ""

BACKED_UP=0
MISSING=0

for file in "${MIRROR_WORLDS_FILES[@]}"; do
    if [ -f "$file" ]; then
        # Create directory structure in backup
        mkdir -p "$BACKUP_DIR/$(dirname "$file")"
        cp "$file" "$BACKUP_DIR/$file"
        echo "   ✅ Backed up: $file"
        BACKED_UP=$((BACKED_UP + 1))
    else
        echo "   ⚠️  Missing: $file"
        MISSING=$((MISSING + 1))
    fi
done

echo ""
echo "📊 Backup Summary:"
echo "   ✅ Files backed up: $BACKED_UP"
echo "   ⚠️  Files missing: $MISSING"
echo ""

# Create backup manifest
cat > "$BACKUP_DIR/BACKUP_MANIFEST.txt" << EOF
MIRROR WORLDS BACKUP MANIFEST
Generated: $(date)
By: Vulcan (The Forge)
For: Anthony Eric Chavez - The Keeper
Signature: VULCAN-THE-FORGE-2025

BACKUP DIRECTORY: $BACKUP_DIR
FILES BACKED UP: $BACKED_UP
FILES MISSING: $MISSING

FILES INCLUDED:
$(for file in "${MIRROR_WORLDS_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (MISSING)"
    fi
done)

TO RESTORE:
1. Copy files from $BACKUP_DIR back to their original locations
2. Run: ./MIRROR_WORLDS_SETUP_AGENT.sh
3. Run: ./LAUNCH_MIRROR_WORLDS.sh

TO REBUILD:
1. Check MIRROR_WORLDS_REBUILD_PLAN.md
2. Follow the rebuild instructions
3. Use this backup as reference
EOF

echo "✅ Backup manifest created: $BACKUP_DIR/BACKUP_MANIFEST.txt"
echo ""

# Create compressed backup
echo "📦 Creating compressed backup..."
tar -czf "${BACKUP_DIR}.tar.gz" "$BACKUP_DIR" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "   ✅ Compressed backup: ${BACKUP_DIR}.tar.gz"
    echo "   Size: $(du -h "${BACKUP_DIR}.tar.gz" | cut -f1)"
else
    echo "   ⚠️  Compression failed (tar may not be available)"
fi

echo ""
echo "══════════════════════════════════════════════════════════════"
echo "✅ BACKUP COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "📦 Backup location: $BACKUP_DIR"
echo "📦 Compressed: ${BACKUP_DIR}.tar.gz"
echo ""
echo "🔄 To restore:"
echo "   tar -xzf ${BACKUP_DIR}.tar.gz"
echo "   cp -r $BACKUP_DIR/* ."
echo ""

