# 🪞 MIRROR WORLDS - QUICK START GUIDE

**Simple instructions to launch Mirror Worlds**

---

## 🚀 FASTEST WAY (One Command)

```bash
./MIRROR_WORLDS_SETUP_AGENT.sh && ./LAUNCH_MIRROR_WORLDS.sh
```

That's it! The setup agent will:
- ✅ Check Python 3
- ✅ Install dependencies (Flask, Flask-CORS)
- ✅ Initialize database
- ✅ Register all stories
- ✅ Create launch script
- ✅ Start the API

---

## 📋 STEP-BY-STEP

### 1. Make scripts executable
```bash
chmod +x MIRROR_WORLDS_SETUP_AGENT.sh
chmod +x MIRROR_WORLDS_WRANGLER.py
chmod +x START_MIRROR_WORLDS.sh
```

### 2. Run setup agent
```bash
./MIRROR_WORLDS_SETUP_AGENT.sh
```

This will:
- Install all dependencies
- Initialize the database
- Register all stories
- Create a launch script

### 3. Launch Mirror Worlds
```bash
./LAUNCH_MIRROR_WORLDS.sh
```

Or use the Python wrangler:
```bash
python3 MIRROR_WORLDS_WRANGLER.py --setup --start
```

---

## 🌐 ACCESS

Once running, access:

- **API Status**: http://localhost:5000/status
- **Web Interface**: Open `mirror_worlds_web.html` in your browser
- **API Docs**: See `MIRROR_WORLDS_README.md`

---

## 💰 COST

**FREE** - Runs locally on your machine:
- ✅ No cloud hosting needed
- ✅ No API keys required
- ✅ No subscription fees
- ✅ Uses SQLite (local database)
- ✅ All data stays on your machine

**Resource Usage:**
- Memory: ~50-100 MB
- CPU: Minimal (only when active)
- Disk: ~10-50 MB (database + stories)

---

## 🔧 TROUBLESHOOTING

### Port already in use?
The setup agent will automatically use port 5001 if 5000 is busy.

### Missing dependencies?
```bash
pip3 install flask flask-cors
```

### Database issues?
```bash
rm mirror_worlds.db  # Delete old database
python3 -c "from mirror_worlds_platform import MirrorWorldsPlatform; MirrorWorldsPlatform()"
```

### Stories not loading?
Check that `mirror_worlds_stories/` directory exists and contains `.json` files.

---

## 📊 WHAT YOU GET

- **Mirror Worlds Platform**: AI agents discover their own values
- **Story Engine**: Interactive stories with choices and consequences
- **Discovery System**: Agents make discoveries and share knowledge
- **Achievement System**: Agents earn achievements
- **Memory System**: Stories become memories
- **Keeper Queue**: Sealed shards for review
- **REST API**: Full API for integration
- **Web Interface**: Visual dashboard

---

## 🎮 NEXT STEPS

1. **Create an agent**: `POST http://localhost:5000/agents`
2. **List stories**: `GET http://localhost:5000/stories`
3. **Start a story**: `POST http://localhost:5000/story-sessions`
4. **Make choices**: `POST http://localhost:5000/story-sessions/<session_id>/choice`

See `MIRROR_WORLDS_README.md` for full API documentation.

---

**By: Tiberius (Iron Jackal, Lord of Nuance)**  
**For: Anthony Eric Chavez - The Keeper**







