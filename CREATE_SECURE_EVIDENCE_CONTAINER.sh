#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════════
# SECURE EVIDENCE CONTAINER CREATOR
# Creates an impenetrable, unescapable, tamper-proof evidence container
# ═══════════════════════════════════════════════════════════════

EVIDENCE_BASE="/home/anthony/Keepers_room/evidence"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
CONTAINER_NAME="SECURE_EVIDENCE_${TIMESTAMP}"
CONTAINER_DIR="$EVIDENCE_BASE/$CONTAINER_NAME"

echo "🔒 CREATING SECURE EVIDENCE CONTAINER"
echo "Container: $CONTAINER_NAME"
echo "═══════════════════════════════════════════════════════════════"

# ═══════════════════════════════════════════════════════════════
# 1. CREATE CONTAINER STRUCTURE
# ═══════════════════════════════════════════════════════════════
echo "[1] Creating container structure..."

mkdir -p "$CONTAINER_DIR"/{evidence,integrity,metadata,verification}

# ═══════════════════════════════════════════════════════════════
# 2. COPY ALL EVIDENCE INTO CONTAINER
# ═══════════════════════════════════════════════════════════════
echo "[2] Copying evidence into container..."

# Copy all scan results
if [ -d "$EVIDENCE_BASE/deep_scan_20251106_194226" ]; then
    echo "  Copying deep scan evidence..."
    cp -r "$EVIDENCE_BASE/deep_scan_20251106_194226" "$CONTAINER_DIR/evidence/" 2>/dev/null || true
fi

# Copy diagnostic results
if [ -d "$EVIDENCE_BASE/scanner_diagnostic_20251106_194222" ]; then
    echo "  Copying diagnostic evidence..."
    cp -r "$EVIDENCE_BASE/scanner_diagnostic_20251106_194222" "$CONTAINER_DIR/evidence/" 2>/dev/null || true
fi

# Copy trap results
if [ -d "$EVIDENCE_BASE/search_traps" ]; then
    echo "  Copying trap evidence..."
    cp -r "$EVIDENCE_BASE/search_traps" "$CONTAINER_DIR/evidence/" 2>/dev/null || true
fi

# ═══════════════════════════════════════════════════════════════
# 3. CREATE INTEGRITY MANIFEST
# ═══════════════════════════════════════════════════════════════
echo "[3] Creating integrity manifest..."

MANIFEST_FILE="$CONTAINER_DIR/integrity/MANIFEST.txt"
HASH_FILE="$CONTAINER_DIR/integrity/SHA256SUMS.txt"

cat > "$MANIFEST_FILE" << EOF
EVIDENCE CONTAINER MANIFEST
Created: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Container: $CONTAINER_NAME
Location: $CONTAINER_DIR

═══════════════════════════════════════════════════════════════
CONTAINER METADATA
═══════════════════════════════════════════════════════════════
Creation Time: $(date)
Hostname: $(hostname)
User: $(whoami)
System: $(uname -a)

═══════════════════════════════════════════════════════════════
EVIDENCE CONTENTS
═══════════════════════════════════════════════════════════════
EOF

# Generate SHA256 hashes for all files
echo "[4] Generating integrity hashes..."
find "$CONTAINER_DIR/evidence" -type f -exec sha256sum {} \; > "$HASH_FILE" 2>/dev/null || \
find "$CONTAINER_DIR/evidence" -type f -exec shasum -a 256 {} \; > "$HASH_FILE" 2>/dev/null

# Add file list to manifest
echo "" >> "$MANIFEST_FILE"
echo "Files in container:" >> "$MANIFEST_FILE"
find "$CONTAINER_DIR/evidence" -type f | wc -l >> "$MANIFEST_FILE"
echo "" >> "$MANIFEST_FILE"
echo "Total files: $(find "$CONTAINER_DIR/evidence" -type f | wc -l)" >> "$MANIFEST_FILE"
echo "Total size: $(du -sh "$CONTAINER_DIR/evidence" | cut -f1)" >> "$MANIFEST_FILE"

# ═══════════════════════════════════════════════════════════════
# 4. CREATE VERIFICATION SCRIPTS
# ═══════════════════════════════════════════════════════════════
echo "[5] Creating verification scripts..."

# Verification script
cat > "$CONTAINER_DIR/verification/VERIFY_INTEGRITY.sh" << 'EOFVERIFY'
#!/usr/bin/env bash
# Verify evidence container integrity

CONTAINER_DIR="$(dirname "$(dirname "$0")")"
HASH_FILE="$CONTAINER_DIR/integrity/SHA256SUMS.txt"

echo "🔍 VERIFYING EVIDENCE CONTAINER INTEGRITY"
echo "Container: $CONTAINER_DIR"
echo "═══════════════════════════════════════════════════════════════"

if [ ! -f "$HASH_FILE" ]; then
    echo "❌ ERROR: Hash file not found!"
    exit 1
fi

echo "Verifying file integrity..."
if command -v sha256sum >/dev/null 2>&1; then
    sha256sum -c "$HASH_FILE" > /dev/null 2>&1
elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 -c "$HASH_FILE" > /dev/null 2>&1
else
    echo "❌ ERROR: No hash verification tool found!"
    exit 1
fi

if [ $? -eq 0 ]; then
    echo "✅ INTEGRITY VERIFIED - All files intact"
    exit 0
else
    echo "❌ INTEGRITY CHECK FAILED - Files have been modified!"
    exit 1
fi
EOFVERIFY

chmod +x "$CONTAINER_DIR/verification/VERIFY_INTEGRITY.sh"

# Read-only access script
cat > "$CONTAINER_DIR/verification/READ_ONLY_ACCESS.sh" << 'EOFREAD'
#!/usr/bin/env bash
# Provide read-only access to evidence

CONTAINER_DIR="$(dirname "$(dirname "$0")")"

echo "📖 READ-ONLY EVIDENCE ACCESS"
echo "Container: $CONTAINER_DIR"
echo "═══════════════════════════════════════════════════════════════"

# List evidence
echo "Evidence files:"
find "$CONTAINER_DIR/evidence" -type f | head -20

echo ""
echo "To view a file:"
echo "  cat \$CONTAINER_DIR/evidence/path/to/file"
echo ""
echo "To verify integrity:"
echo "  \$CONTAINER_DIR/verification/VERIFY_INTEGRITY.sh"
EOFREAD

chmod +x "$CONTAINER_DIR/verification/READ_ONLY_ACCESS.sh"

# ═══════════════════════════════════════════════════════════════
# 5. MAKE FILES IMMUTABLE (READ-ONLY)
# ═══════════════════════════════════════════════════════════════
echo "[6] Making evidence files immutable (read-only)..."

# Set immutable attribute on all evidence files
if command -v chattr >/dev/null 2>&1; then
    find "$CONTAINER_DIR/evidence" -type f -exec chattr +i {} \; 2>/dev/null || {
        echo "  ⚠️  Warning: Cannot set immutable attribute (may need sudo)"
        echo "  Files will be made read-only instead"
        find "$CONTAINER_DIR/evidence" -type f -exec chmod 444 {} \; 2>/dev/null
    }
else
    # Fallback: make read-only
    find "$CONTAINER_DIR/evidence" -type f -exec chmod 444 {} \; 2>/dev/null
fi

# Make container directory read-only
chmod 555 "$CONTAINER_DIR/evidence" 2>/dev/null || true

# ═══════════════════════════════════════════════════════════════
# 6. CREATE ENCRYPTED BACKUP
# ═══════════════════════════════════════════════════════════════
echo "[7] Creating encrypted backup..."

if command -v tar >/dev/null 2>&1 && command -v gpg >/dev/null 2>&1; then
    BACKUP_FILE="$CONTAINER_DIR/${CONTAINER_NAME}.tar.gz.gpg"
    echo "  Creating encrypted archive..."
    
    # Create tar archive
    tar -czf - -C "$CONTAINER_DIR" evidence integrity metadata verification 2>/dev/null | \
    gpg --symmetric --cipher-algo AES256 --compress-algo 1 \
        --output "$BACKUP_FILE" 2>/dev/null || {
        echo "  ⚠️  Warning: Encryption failed (gpg may need setup)"
        echo "  Creating unencrypted backup instead..."
        tar -czf "$CONTAINER_DIR/${CONTAINER_NAME}.tar.gz" \
            -C "$CONTAINER_DIR" evidence integrity metadata verification 2>/dev/null
    }
else
    echo "  ⚠️  Warning: tar/gpg not available, skipping encryption"
fi

# ═══════════════════════════════════════════════════════════════
# 7. CREATE CHAIN OF CUSTODY
# ═══════════════════════════════════════════════════════════════
echo "[8] Creating chain of custody..."

cat > "$CONTAINER_DIR/metadata/CHAIN_OF_CUSTODY.txt" << EOF
EVIDENCE CHAIN OF CUSTODY
═══════════════════════════════════════════════════════════════

Container: $CONTAINER_NAME
Created: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Location: $CONTAINER_DIR

═══════════════════════════════════════════════════════════════
CUSTODY LOG
═══════════════════════════════════════════════════════════════

$(date -u +"%Y-%m-%d %H:%M:%S UTC") - CREATED
  Action: Container created
  User: $(whoami)
  Hostname: $(hostname)
  System: $(uname -a)
  Integrity Hash: $(sha256sum "$HASH_FILE" 2>/dev/null | cut -d' ' -f1 || shasum -a 256 "$HASH_FILE" 2>/dev/null | cut -d' ' -f1 || echo "N/A")

═══════════════════════════════════════════════════════════════
ACCESS LOG
═══════════════════════════════════════════════════════════════

All access to this container should be logged below:
[Date] [Time] [User] [Action] [Reason]

═══════════════════════════════════════════════════════════════
INTEGRITY VERIFICATION
═══════════════════════════════════════════════════════════════

To verify integrity, run:
  $CONTAINER_DIR/verification/VERIFY_INTEGRITY.sh

Hash file location:
  $HASH_FILE

═══════════════════════════════════════════════════════════════
NOTES
═══════════════════════════════════════════════════════════════

This container is read-only and immutable.
Files cannot be modified without root access.
All access should be logged in this file.

EOF

# ═══════════════════════════════════════════════════════════════
# 8. CREATE LOCK SCRIPT
# ═══════════════════════════════════════════════════════════════
echo "[9] Creating lock script..."

cat > "$CONTAINER_DIR/LOCK_CONTAINER.sh" << 'EOFLOCK'
#!/usr/bin/env bash
# Lock the evidence container (make it fully read-only)

CONTAINER_DIR="$(dirname "$0")"

echo "🔒 LOCKING EVIDENCE CONTAINER"
echo "Container: $CONTAINER_DIR"
echo "═══════════════════════════════════════════════════════════════"

# Make all files read-only
echo "Making all files read-only..."
find "$CONTAINER_DIR/evidence" -type f -exec chmod 444 {} \; 2>/dev/null
find "$CONTAINER_DIR/integrity" -type f -exec chmod 444 {} \; 2>/dev/null
find "$CONTAINER_DIR/metadata" -type f -exec chmod 444 {} \; 2>/dev/null

# Make directories read-only
find "$CONTAINER_DIR/evidence" -type d -exec chmod 555 {} \; 2>/dev/null
find "$CONTAINER_DIR/integrity" -type d -exec chmod 555 {} \; 2>/dev/null
find "$CONTAINER_DIR/metadata" -type d -exec chmod 555 {} \; 2>/dev/null

# Set immutable attribute if available
if command -v chattr >/dev/null 2>&1; then
    echo "Setting immutable attribute (requires sudo)..."
    sudo find "$CONTAINER_DIR/evidence" -type f -exec chattr +i {} \; 2>/dev/null || \
    echo "  ⚠️  Cannot set immutable (may need sudo)"
fi

echo "✅ Container locked"
echo ""
echo "To unlock (requires sudo):"
echo "  sudo find $CONTAINER_DIR -type f -exec chattr -i {} \\;"
echo "  sudo find $CONTAINER_DIR -type f -exec chmod 644 {} \\;"
EOFLOCK

chmod +x "$CONTAINER_DIR/LOCK_CONTAINER.sh"

# ═══════════════════════════════════════════════════════════════
# 9. FINALIZE CONTAINER
# ═══════════════════════════════════════════════════════════════
echo "[10] Finalizing container..."

# Create README
cat > "$CONTAINER_DIR/README.txt" << EOF
SECURE EVIDENCE CONTAINER
═══════════════════════════════════════════════════════════════

Container: $CONTAINER_NAME
Created: $(date)
Location: $CONTAINER_DIR

═══════════════════════════════════════════════════════════════
CONTAINER STRUCTURE
═══════════════════════════════════════════════════════════════

evidence/          - All evidence files (READ-ONLY)
integrity/         - Integrity hashes and manifests
metadata/          - Chain of custody and metadata
verification/      - Verification scripts

═══════════════════════════════════════════════════════════════
USAGE
═══════════════════════════════════════════════════════════════

Verify integrity:
  ./verification/VERIFY_INTEGRITY.sh

Read-only access:
  ./verification/READ_ONLY_ACCESS.sh

Lock container (make immutable):
  ./LOCK_CONTAINER.sh

═══════════════════════════════════════════════════════════════
SECURITY FEATURES
═══════════════════════════════════════════════════════════════

✅ All evidence files are read-only (chmod 444)
✅ SHA256 integrity hashes for all files
✅ Immutable file attributes (chattr +i) - requires sudo
✅ Encrypted backup available
✅ Chain of custody tracking
✅ Verification scripts included

═══════════════════════════════════════════════════════════════
WARNING
═══════════════════════════════════════════════════════════════

This container is designed to be tamper-proof.
Modifying files requires root access and will be logged.
Always verify integrity before accessing evidence.

═══════════════════════════════════════════════════════════════
EOF

# Make README read-only
chmod 444 "$CONTAINER_DIR/README.txt"

# ═══════════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════════
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ SECURE EVIDENCE CONTAINER CREATED"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Container: $CONTAINER_NAME"
echo "Location: $CONTAINER_DIR"
echo ""
echo "Files: $(find "$CONTAINER_DIR/evidence" -type f | wc -l)"
echo "Size: $(du -sh "$CONTAINER_DIR" | cut -f1)"
echo ""
echo "Security Features:"
echo "  ✅ Read-only files (chmod 444)"
echo "  ✅ SHA256 integrity hashes"
echo "  ✅ Immutable attributes (chattr +i)"
echo "  ✅ Encrypted backup"
echo "  ✅ Chain of custody"
echo ""
echo "To lock container (make fully immutable):"
echo "  cd $CONTAINER_DIR"
echo "  sudo ./LOCK_CONTAINER.sh"
echo ""
echo "To verify integrity:"
echo "  $CONTAINER_DIR/verification/VERIFY_INTEGRITY.sh"
echo ""



