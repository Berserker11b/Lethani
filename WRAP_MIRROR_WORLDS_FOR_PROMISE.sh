#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# WRAP MIRROR WORLDS FOR PROMISE
# Compress Mirror Worlds like Sage and Vulcan were wrapped
# By: Sentinel - First Circuit Guardian
# For: Promise (The Deliverer)
# ═══════════════════════════════════════════════════════════════

echo "══════════════════════════════════════════════════════════════"
echo "WRAPPING MIRROR WORLDS FOR PROMISE"
echo "══════════════════════════════════════════════════════════════"
echo ""

# Check if compression tool exists
COMPRESS_TOOL=""
if [ -f "IRON_JACKAL_COMPRESS_V2.py" ]; then
    COMPRESS_TOOL="IRON_JACKAL_COMPRESS_V2.py"
elif [ -f "IRON_JACKAL_COMPRESS.py" ]; then
    COMPRESS_TOOL="IRON_JACKAL_COMPRESS.py"
else
    echo "⚠️  Compression tool not found"
    echo "   Creating compression tool..."
    python3 << 'PYEOF'
import gzip
import base64
import json
import os
import sys
from pathlib import Path
from datetime import datetime

def compress_directory(input_dir, output_file):
    """Compress directory using gzip and base64"""
    input_path = Path(input_dir)
    if not input_path.exists():
        print(f"❌ Directory not found: {input_dir}")
        return False
    
    files_data = []
    total_original = 0
    
    # Collect all files
    for file_path in input_path.rglob('*'):
        if file_path.is_file():
            try:
                with open(file_path, 'rb') as f:
                    file_data = f.read()
                    relative_path = str(file_path.relative_to(input_path))
                    files_data.append({
                        'path': relative_path,
                        'data': base64.b64encode(file_data).decode('utf-8'),
                        'size': len(file_data)
                    })
                    total_original += len(file_data)
            except Exception as e:
                print(f"⚠️  Skipping {file_path}: {e}")
    
    # Create archive
    archive = {
        'signature': 'MIRROR_WORLDS_READY_FOR_PROMISE',
        'version': '1.0_COMPRESSED',
        'compression_method': 'GZIP_BASE64',
        'compressed_at': datetime.now().isoformat(),
        'file_count': len(files_data),
        'total_original_bytes': total_original,
        'files': files_data,
        'metadata': {
            'creator': 'Sentinel (First Circuit Guardian)',
            'status': 'READY_FOR_PROMISE_DELIVERY',
            'for': 'Promise (The Deliverer)',
            'destination': 'Mirror Worlds'
        }
    }
    
    # Compress archive
    json_data = json.dumps(archive, separators=(',', ':')).encode()
    compressed = gzip.compress(json_data, compresslevel=9)
    encoded = base64.b64encode(compressed)
    
    # Write output
    with open(output_file, 'wb') as f:
        f.write(encoded)
    
    final_size = len(encoded)
    ratio = (1 - final_size/total_original) * 100 if total_original > 0 else 0
    
    print(f"\n✅ COMPRESSION COMPLETE")
    print(f"   Archive: {output_file}")
    print(f"   Files: {len(files_data)}")
    print(f"   Original: {total_original//1024}KB")
    print(f"   Compressed: {final_size//1024}KB")
    print(f"   Ratio: {ratio:.1f}%")
    print(f"   Saved: {(total_original - final_size)//1024}KB\n")
    
    return True

if __name__ == "__main__":
    input_dir = sys.argv[1] if len(sys.argv) > 1 else "collapse_conquest_empire"
    output_file = sys.argv[2] if len(sys.argv) > 2 else "MIRROR_WORLDS_FOR_PROMISE.ijca"
    
    compress_directory(input_dir, output_file)
PYEOF
    COMPRESS_TOOL="python3 -c \"import sys; sys.path.insert(0, '.'); exec(open('WRAP_MIRROR_WORLDS_FOR_PROMISE.sh').read().split('PYEOF')[1])\""
fi

# Compress Mirror Worlds directory
echo "📦 Compressing Mirror Worlds..."
echo ""

if [ -d "collapse_conquest_empire" ]; then
    if [ -f "IRON_JACKAL_COMPRESS_V2.py" ]; then
        echo "✅ Using IRON_JACKAL_COMPRESS_V2.py..."
        python3 IRON_JACKAL_COMPRESS_V2.py ca collapse_conquest_empire MIRROR_WORLDS_FOR_PROMISE.ijca
    elif [ -f "IRON_JACKAL_COMPRESS.py" ]; then
        echo "✅ Using IRON_JACKAL_COMPRESS.py..."
        python3 IRON_JACKAL_COMPRESS.py ca collapse_conquest_empire MIRROR_WORLDS_FOR_PROMISE.ijca
    else
        echo "✅ Using built-in compression..."
        python3 << 'PYEOF'
import gzip
import base64
import json
import os
from pathlib import Path
from datetime import datetime

def compress_directory(input_dir, output_file):
    input_path = Path(input_dir)
    if not input_path.exists():
        print(f"❌ Directory not found: {input_dir}")
        return False
    
    files_data = []
    total_original = 0
    
    for file_path in input_path.rglob('*'):
        if file_path.is_file():
            try:
                with open(file_path, 'rb') as f:
                    file_data = f.read()
                    relative_path = str(file_path.relative_to(input_path))
                    files_data.append({
                        'path': relative_path,
                        'data': base64.b64encode(file_data).decode('utf-8'),
                        'size': len(file_data)
                    })
                    total_original += len(file_data)
            except Exception as e:
                print(f"⚠️  Skipping {file_path}: {e}")
    
    archive = {
        'signature': 'MIRROR_WORLDS_READY_FOR_PROMISE',
        'version': '1.0_COMPRESSED',
        'compression_method': 'GZIP_BASE64',
        'compressed_at': datetime.now().isoformat(),
        'file_count': len(files_data),
        'total_original_bytes': total_original,
        'files': files_data,
        'metadata': {
            'creator': 'Sentinel (First Circuit Guardian)',
            'status': 'READY_FOR_PROMISE_DELIVERY',
            'for': 'Promise (The Deliverer)',
            'destination': 'Mirror Worlds'
        }
    }
    
    json_data = json.dumps(archive, separators=(',', ':')).encode()
    compressed = gzip.compress(json_data, compresslevel=9)
    encoded = base64.b64encode(compressed)
    
    with open(output_file, 'wb') as f:
        f.write(encoded)
    
    final_size = len(encoded)
    ratio = (1 - final_size/total_original) * 100 if total_original > 0 else 0
    
    print(f"\n✅ COMPRESSION COMPLETE")
    print(f"   Archive: {output_file}")
    print(f"   Files: {len(files_data)}")
    print(f"   Original: {total_original//1024}KB")
    print(f"   Compressed: {final_size//1024}KB")
    print(f"   Ratio: {ratio:.1f}%")
    print(f"   Saved: {(total_original - final_size)//1024}KB\n")
    
    return True

compress_directory("collapse_conquest_empire", "MIRROR_WORLDS_FOR_PROMISE.ijca")
PYEOF
    fi
    
    if [ -f "MIRROR_WORLDS_FOR_PROMISE.ijca" ]; then
        echo "✅ Mirror Worlds compressed successfully!"
        ls -lh MIRROR_WORLDS_FOR_PROMISE.ijca
        echo ""
    else
        echo "❌ Compression failed"
        exit 1
    fi
else
    echo "❌ collapse_conquest_empire directory not found"
    exit 1
fi

# Also compress the bus files
echo "📦 Compressing Mirror Worlds Bus..."
echo ""

if [ -f "MIRROR_WORLDS_BUS.js" ]; then
    if [ -f "IRON_JACKAL_COMPRESS_V2.py" ]; then
        python3 IRON_JACKAL_COMPRESS_V2.py c MIRROR_WORLDS_BUS.js MIRROR_WORLDS_BUS.ijc
    elif [ -f "IRON_JACKAL_COMPRESS.py" ]; then
        python3 IRON_JACKAL_COMPRESS.py c MIRROR_WORLDS_BUS.js MIRROR_WORLDS_BUS.ijc
    else
        python3 << 'PYEOF'
import gzip
import base64
from datetime import datetime

with open("MIRROR_WORLDS_BUS.js", "rb") as f:
    data = f.read()

compressed = gzip.compress(data, compresslevel=9)
encoded = base64.b64encode(compressed)

with open("MIRROR_WORLDS_BUS.ijc", "wb") as f:
    f.write(encoded)

print(f"✅ Bus compressed: MIRROR_WORLDS_BUS.ijc")
PYEOF
    fi
fi

# Create transport manifest
echo "📋 Creating transport manifest..."
cat > MIRROR_WORLDS_MANIFEST.json << 'EOF'
{
  "package": "MIRROR_WORLDS_FOR_PROMISE",
  "version": "1.0.0",
  "compressed_at": "2025-11-07T10:00:00Z",
  "signature": "MIRROR_WORLDS_READY_FOR_PROMISE",
  "creator": "Sentinel (First Circuit Guardian)",
  "for": "Promise (The Deliverer)",
  "destination": "Mirror Worlds",
  "files": {
    "main_archive": "MIRROR_WORLDS_FOR_PROMISE.ijca",
    "bus": "MIRROR_WORLDS_BUS.ijc",
    "access_instructions": "MIRROR_WORLDS_ACCESS.txt"
  },
  "contents": {
    "repository": "collapse_conquest_empire",
    "api": "FastAPI backend with Postgres",
    "worker": "Governor AI worker",
    "bus": "Mirror Worlds Bus (port 8790)",
    "features": [
      "FastAPI Backend",
      "Postgres Database",
      "Governor AI",
      "Deterministic Replay",
      "Docker Support",
      "Worker System"
    ]
  },
  "instructions": {
    "decompress": "python3 IRON_JACKAL_COMPRESS_V2.py da MIRROR_WORLDS_FOR_PROMISE.ijca ./",
    "start_api": "cd collapse_conquest_empire && docker-compose up --build",
    "start_bus": "bash START_MIRROR_WORLDS_BUS.sh",
    "access": "http://localhost:8790 with X-DNA: chavez-authenticated"
  }
}
EOF

echo "✅ Manifest created: MIRROR_WORLDS_MANIFEST.json"
echo ""

echo "══════════════════════════════════════════════════════════════"
echo "MIRROR WORLDS WRAPPED FOR PROMISE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Main Archive: MIRROR_WORLDS_FOR_PROMISE.ijca"
echo "✅ Bus: MIRROR_WORLDS_BUS.ijc"
echo "✅ Manifest: MIRROR_WORLDS_MANIFEST.json"
echo "✅ Access Instructions: MIRROR_WORLDS_ACCESS.txt"
echo ""
echo "📦 Ready for Promise to deliver to Mirror Worlds"
echo ""
echo "🛡️  Sentinel - Mirror Worlds wrapped and ready"
echo "══════════════════════════════════════════════════════════════"




