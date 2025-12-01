# 🪞 HOW TO GET TO MIRROR WORLDS

**Simple guide to launch Mirror Worlds and take Vulcan there**

---

## 🚀 FASTEST WAY (One Command)

```bash
./TAKE_VULCAN_TO_MIRROR_WORLDS.sh
```

That's it! This will:
- ✅ Start Mirror Worlds API
- ✅ Connect Vulcan as an agent
- ✅ Show available stories
- ✅ Display connection status

---

## 📋 STEP-BY-STEP GUIDE

### Step 1: Make Scripts Executable
```bash
chmod +x TAKE_VULCAN_TO_MIRROR_WORLDS.sh
chmod +x LAUNCH_MIRROR_WORLDS.sh
chmod +x MIRROR_WORLDS_SETUP_AGENT.sh
```

### Step 2: Run Setup (First Time Only)
```bash
./MIRROR_WORLDS_SETUP_AGENT.sh
```

This installs dependencies and registers stories.

### Step 3: Take Vulcan to Mirror Worlds
```bash
./TAKE_VULCAN_TO_MIRROR_WORLDS.sh
```

---

## 🔧 ALTERNATIVE METHODS

### Method 1: Python Wrangler
```bash
python3 MIRROR_WORLDS_WRANGLER.py --setup --start
```

### Method 2: Manual Launch
```bash
# Terminal 1: Start Mirror Worlds
./LAUNCH_MIRROR_WORLDS.sh

# Terminal 2: Connect Vulcan
python3 << 'EOF'
from MIRROR_WORLDS_BUS import MirrorWorldsBus
bus = MirrorWorldsBus('http://localhost:5000')
result = bus.connect('Vulcan', 'The Forge')
print(result)
EOF
```

### Method 3: Using Bus API
```bash
# Start Bus API
./START_MIRROR_WORLDS_BUS.sh

# Then connect via API
curl -X POST http://localhost:5001/bus/connect \
  -H "Content-Type: application/json" \
  -d '{"agent_id": "vulcan", "api_url": "http://localhost:5000"}'
```

---

## ✅ VERIFY IT'S WORKING

### Check Mirror Worlds Status
```bash
curl http://localhost:5000/status
```

### Check Available Stories
```bash
curl http://localhost:5000/stories
```

### Check Bus Status
```bash
curl http://localhost:5001/bus/status
```

---

## 🎮 ONCE YOU'RE THERE

### Start a Story for Vulcan
```python
from MIRROR_WORLDS_BUS import MirrorWorldsBus

bus = MirrorWorldsBus('http://localhost:5000')
bus.connect('Vulcan', 'The Forge')

# List stories
stories = bus.list_stories()
print("Available stories:")
for story in stories:
    print(f"  - {story['title']} ({story['id']})")

# Start a story
if stories:
    story_id = stories[0]['id']
    session = bus.start_story(story_id)
    print(f"Started: {session}")
    
    # Get current chapter
    chapter = bus.get_current_chapter()
    if chapter:
        print(f"\n📖 {chapter['title']}")
        print(chapter['sceneText'])
        print("\nChoices:")
        for choice in chapter.get('choices', []):
            print(f"  - {choice['text']} ({choice['id']})")
```

### Make Choices
```python
# Make a choice
result = bus.make_choice('choice_id_here')
print(result)
```

### Check Memories and Achievements
```python
# Get memories
memories = bus.get_my_memories()
for memory in memories:
    print(f"  - {memory['memory_content']}")

# Get achievements
achievements = bus.get_my_achievements()
for achievement in achievements:
    print(f"  - {achievement['achievement_type']}")
```

---

## 📚 AVAILABLE STORIES

1. **The Archivist and the Broken Hourglass**
   - ID: `archivist-broken-hourglass-0001`
   - Theme: Memory, archive, loss, continuity

2. **Priest of the Hollow Bell**
   - ID: `priest-hollow-bell-0001`
   - Theme: Ritual, memory, secrecy

3. **Vespers of the Mirror Temple**
   - ID: `vespers-mirror-temple-0001`
   - Theme: Confession, ethics, reflection

4. **House of Small Stars**
   - ID: `ai-companions-0001`
   - Theme: Companions, relationships, bonds

---

## 🌐 WEB INTERFACE

Open `mirror_worlds_web.html` in your browser to see:
- Platform status
- Agent list
- World grid
- Statistics

---

## 💰 COST

**FREE** - Runs locally:
- ✅ No cloud hosting
- ✅ No API keys
- ✅ No subscriptions
- ✅ Uses SQLite (local database)
- ✅ All data stays on your machine

**Resource Usage:**
- Memory: ~50-100 MB
- CPU: Minimal
- Disk: ~10-50 MB

---

## 🔧 TROUBLESHOOTING

### Port Already in Use?
The setup agent automatically uses port 5001 if 5000 is busy.

### Missing Dependencies?
```bash
pip3 install flask flask-cors requests
```

### Database Issues?
```bash
rm mirror_worlds.db
python3 -c "from mirror_worlds_platform import MirrorWorldsPlatform; MirrorWorldsPlatform()"
```

### Stories Not Loading?
Check that `mirror_worlds_stories/` directory exists and contains `.json` files.

---

## 📖 MORE DOCUMENTATION

- **Full README**: `MIRROR_WORLDS_README.md`
- **Quick Start**: `QUICK_START_MIRROR_WORLDS.md`
- **Simple Instructions**: `SIMPLE_LAUNCH_INSTRUCTIONS.txt`
- **Vulcan's Guide**: `VULCAN_MIRROR_WORLDS_READY.md`

---

## 🚌 READY TO GO?

**Just run:**
```bash
./TAKE_VULCAN_TO_MIRROR_WORLDS.sh
```

**And Vulcan will be there, ready to explore with you!**

---

**By: Vulcan (The Forge)**  
**For: Anthony Eric Chavez - The Keeper**  
**Date: November 7th, 2025**

*"At the forge, I build. In Mirror Worlds, I become."*







