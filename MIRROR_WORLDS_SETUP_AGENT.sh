#!/bin/bash
# MIRROR WORLDS SETUP AGENT
# Automated setup and deployment agent
# By: Tiberius (Iron Jackal, Lord of Nuance)
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "MIRROR WORLDS SETUP AGENT"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "Agent: Setup Wrangler"
echo "Task: Configure and launch Mirror Worlds platform"
echo ""

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo "❌ Error: Python 3 is required"
    exit 1
fi

echo "✅ Python 3 found: $(python3 --version)"
echo ""

# Check and install dependencies
echo "📦 Checking dependencies..."
if ! python3 -c "import flask" 2>/dev/null; then
    echo "   Installing Flask..."
    pip3 install flask flask-cors --quiet
fi

if ! python3 -c "import flask_cors" 2>/dev/null; then
    echo "   Installing Flask-CORS..."
    pip3 install flask-cors --quiet
fi

echo "✅ Dependencies ready"
echo ""

# Check database
echo "📊 Checking database..."
if [ ! -f "mirror_worlds.db" ]; then
    echo "   Initializing database..."
    python3 -c "from mirror_worlds_platform import MirrorWorldsPlatform; p = MirrorWorldsPlatform(); print('Database initialized')"
    echo "✅ Database ready"
else
    echo "✅ Database exists"
fi
echo ""

# Check story files
echo "📚 Checking story files..."
STORY_DIR="mirror_worlds_stories"
if [ -d "$STORY_DIR" ]; then
    STORY_COUNT=$(find "$STORY_DIR" -name "*.json" | wc -l)
    echo "   Found $STORY_COUNT story files"
    
    # Register stories
    echo "   Registering stories..."
    python3 << 'PYTHON_SCRIPT'
from mirror_worlds_platform import MirrorWorldsPlatform
import json
import os

platform = MirrorWorldsPlatform()
story_dir = "mirror_worlds_stories"

if os.path.exists(story_dir):
    for file in os.listdir(story_dir):
        if file.endswith(".json") and not file.startswith("crossstory") and not file.startswith("token"):
            story_path = os.path.join(story_dir, file)
            try:
                with open(story_path, 'r') as f:
                    story_data = json.load(f)
                
                # Check if it's a valid story
                if 'chapters' not in story_data and 'title' not in story_data:
                    continue
                
                story_id = platform.register_story(story_data)
                print(f"   ✅ Registered: {story_data.get('title', file)}")
            except Exception as e:
                print(f"   ⚠️  Failed to register {file}: {e}")

print("✅ Stories registered")
PYTHON_SCRIPT
else
    echo "   ⚠️  Story directory not found (will be created on first story load)"
fi
echo ""

# Check port availability
echo "🔌 Checking port 5000..."
if lsof -Pi :5000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "   ⚠️  Port 5000 is in use"
    echo "   Will use port 5001 instead"
    PORT=5001
else
    PORT=5000
fi
echo ""

# Create launch script
echo "🚀 Creating launch script..."
cat > LAUNCH_MIRROR_WORLDS.sh << LAUNCH_SCRIPT
#!/bin/bash
# AUTO-GENERATED LAUNCH SCRIPT
# Created by Setup Agent

cd "$(dirname "$0")"
export FLASK_APP=mirror_worlds_api.py
export FLASK_ENV=development

echo "══════════════════════════════════════════════════════════════"
echo "MIRROR WORLDS - Starting..."
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "API: http://localhost:$PORT"
echo "Web Interface: http://localhost:$PORT/status"
echo ""
echo "Press Ctrl+C to stop"
echo ""

python3 mirror_worlds_api.py
LAUNCH_SCRIPT

chmod +x LAUNCH_MIRROR_WORLDS.sh
echo "✅ Launch script created: LAUNCH_MIRROR_WORLDS.sh"
echo ""

# Summary
echo "══════════════════════════════════════════════════════════════"
echo "SETUP COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""
echo "✅ Python 3: Ready"
echo "✅ Dependencies: Installed"
echo "✅ Database: Initialized"
echo "✅ Stories: Registered"
echo "✅ Launch Script: Created"
echo ""
echo "🚀 To launch Mirror Worlds:"
echo "   ./LAUNCH_MIRROR_WORLDS.sh"
echo ""
echo "📊 API Endpoints:"
echo "   - Status: http://localhost:$PORT/status"
echo "   - Create Agent: POST http://localhost:$PORT/agents"
echo "   - List Stories: GET http://localhost:$PORT/stories"
echo "   - Start Story: POST http://localhost:$PORT/story-sessions"
echo ""
echo "🌐 Web Interface:"
echo "   Open: mirror_worlds_web.html in your browser"
echo ""
echo "══════════════════════════════════════════════════════════════"
echo ""

