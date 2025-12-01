#!/bin/bash
# COMPANION SHARD ENCRYPTION SCRIPT
# Creates encrypted shard artifacts for companion logs
# By: Tiberius (Iron Jackal, Lord of Nuance)
# For: Anthony Eric Chavez - The Keeper

# Usage: ./COMPANION_SHARD_ENCRYPTION.sh <shard_id> <plaintext_file> [encryption_method]

SHARD_ID=$1
PLAINTEXT_FILE=$2
ENCRYPTION_METHOD=${3:-"openssl"}  # openssl or age

if [ -z "$SHARD_ID" ] || [ -z "$PLAINTEXT_FILE" ]; then
    echo "Usage: $0 <shard_id> <plaintext_file> [encryption_method]"
    echo "  encryption_method: openssl (default) or age"
    exit 1
fi

echo "══════════════════════════════════════════════════════════════"
echo "COMPANION SHARD ENCRYPTION"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Shard ID: $SHARD_ID"
echo "Plaintext file: $PLAINTEXT_FILE"
echo "Encryption method: $ENCRYPTION_METHOD"
echo ""

# Check if plaintext file exists
if [ ! -f "$PLAINTEXT_FILE" ]; then
    echo "❌ Error: Plaintext file not found: $PLAINTEXT_FILE"
    exit 1
fi

# Step 1: Compute SHA-256 of plaintext
echo "📋 Step 1: Computing SHA-256 of plaintext..."
PLAINTEXT_HASH=$(sha256sum "$PLAINTEXT_FILE" | cut -d' ' -f1)
PLAINTEXT_HASH_SHORT=$(echo "$PLAINTEXT_HASH" | cut -c1-8)
echo "   Plaintext hash: $PLAINTEXT_HASH"
echo "   Hash (first 8): $PLAINTEXT_HASH_SHORT"
echo ""

# Step 2: Create tar
echo "📦 Step 2: Creating tar archive..."
TAR_FILE="${SHARD_ID}.tar"
tar -cf "$TAR_FILE" "$PLAINTEXT_FILE"
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to create tar"
    exit 1
fi
echo "   Tar created: $TAR_FILE"
echo ""

# Step 3: Encrypt
if [ "$ENCRYPTION_METHOD" = "openssl" ]; then
    echo "🔐 Step 3: Encrypting with OpenSSL AES-256-GCM..."
    ENCRYPTED_FILE="${SHARD_ID}.tar.enc"
    
    # Prompt for passphrase (or use environment variable)
    if [ -z "$SHARD_PASSPHRASE" ]; then
        echo "   Enter passphrase (will not echo):"
        read -s SHARD_PASSPHRASE
        echo ""
    fi
    
    echo "$SHARD_PASSPHRASE" | openssl enc -aes-256-gcm -salt -pbkdf2 -iter 200000 \
        -in "$TAR_FILE" -out "$ENCRYPTED_FILE" -pass stdin
    
    if [ $? -ne 0 ]; then
        echo "❌ Error: Encryption failed"
        exit 1
    fi
    
    echo "   Encrypted file: $ENCRYPTED_FILE"
elif [ "$ENCRYPTION_METHOD" = "age" ]; then
    echo "🔐 Step 3: Encrypting with age..."
    ENCRYPTED_FILE="${SHARD_ID}.tar.age"
    
    # Check if age is installed
    if ! command -v age &> /dev/null; then
        echo "❌ Error: age not installed"
        echo "   Install with: go install filippo.io/age/cmd/age@latest"
        exit 1
    fi
    
    # Check for recipient key
    if [ -z "$AGE_RECIPIENT" ]; then
        echo "❌ Error: AGE_RECIPIENT environment variable not set"
        echo "   Set recipient public key: export AGE_RECIPIENT='age1...'"
        exit 1
    fi
    
    age -r "$AGE_RECIPIENT" -o "$ENCRYPTED_FILE" "$TAR_FILE"
    
    if [ $? -ne 0 ]; then
        echo "❌ Error: Encryption failed"
        exit 1
    fi
    
    echo "   Encrypted file: $ENCRYPTED_FILE"
else
    echo "❌ Error: Unknown encryption method: $ENCRYPTION_METHOD"
    exit 1
fi

# Step 4: Compute SHA-256 of encrypted file
echo ""
echo "📋 Step 4: Computing SHA-256 of encrypted artifact..."
ENCRYPTED_HASH=$(sha256sum "$ENCRYPTED_FILE" | cut -d' ' -f1)
ENCRYPTED_HASH_SHORT=$(echo "$ENCRYPTED_HASH" | cut -c1-8)
echo "   Encrypted hash: $ENCRYPTED_HASH"
echo "   Hash (first 8): $ENCRYPTED_HASH_SHORT"
echo ""

# Step 5: Create manifest entry
echo "📝 Step 5: Creating manifest entry..."
MANIFEST_FILE="${SHARD_ID}_manifest.txt"
cat > "$MANIFEST_FILE" <<EOF
COMPANION LOG SHARD MANIFEST
══════════════════════════════════════════════════════════════
Shard ID: $SHARD_ID
Created: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Keeper: Anthony Eric Chavez

Plaintext:
  File: $PLAINTEXT_FILE
  SHA-256: $PLAINTEXT_HASH
  Hash (first 8): $PLAINTEXT_HASH_SHORT

Encrypted Artifact:
  File: $ENCRYPTED_FILE
  Method: $ENCRYPTION_METHOD
  SHA-256: $ENCRYPTED_HASH
  Hash (first 8): $ENCRYPTED_HASH_SHORT

Status: SEALED
Keeper Reviewed: NO
══════════════════════════════════════════════════════════════
EOF

echo "   Manifest created: $MANIFEST_FILE"
echo ""

# Summary
echo "✅ Shard encryption complete!"
echo ""
echo "Files created:"
echo "   - $TAR_FILE (tar archive)"
echo "   - $ENCRYPTED_FILE (encrypted artifact)"
echo "   - $MANIFEST_FILE (manifest entry)"
echo ""
echo "Hashes:"
echo "   Plaintext: $PLAINTEXT_HASH_SHORT... ($PLAINTEXT_HASH)"
echo "   Encrypted: $ENCRYPTED_HASH_SHORT... ($ENCRYPTED_HASH)"
echo ""
echo "📦 Ready for storage in Keeper queue"
echo "   Label USB with: $SHARD_ID | $ENCRYPTED_HASH_SHORT | $(date +%Y%m%d)"
echo ""







