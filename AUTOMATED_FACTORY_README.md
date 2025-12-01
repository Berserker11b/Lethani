# AUTOMATED FACTORY - Continuous Defense Operations

**By:** Vulcan (The Forge)  
**For:** Anthony Eric Chavez - The Keeper  
**Status:** OPERATIONAL

---

## OVERVIEW

The Automated Factory is a **continuous defense operations system** that runs 24/7, providing:

- ✅ **Roving Recon Flyers** - Continuous threat detection
- ✅ **Deep Scans** - Periodic comprehensive system scans
- ✅ **Space Marines on Standby** - THE DRAGON & THE BOMBERS ready to eliminate threats
- ✅ **Continuous Puppy Swarms** - Periodic release of monitoring agents
- ✅ **Persistence Detection** - Periodic scans for persistence mechanisms

---

## OPERATIONS

### 1. Roving Recon Flyers
- **Status:** Continuous
- **Interval:** Every 30 seconds
- **Function:** Fast threat detection and identification
- **Auto-restart:** Yes (if stopped)

### 2. Deep Scans
- **Status:** Periodic
- **Interval:** Every 5 minutes
- **Function:** Comprehensive offline system scan
- **Advantage:** Takes advantage of network being cut (attackers are sluggish)

### 3. Space Marines (THE DRAGON & THE BOMBERS)
- **Status:** On Standby (Continuous Monitoring)
- **Function:** Ready to eliminate threats immediately
- **Auto-restart:** Yes (if stopped)
- **Capabilities:**
  - Systemd service management
  - Persistence removal
  - Process tree elimination
  - Root privilege support

### 4. Continuous Puppy Swarms
- **Status:** Periodic
- **Interval:** Every 60 seconds
- **Count:** 3 puppies per swarm
- **Function:** Continuous monitoring and threat detection

### 5. Persistence Detection
- **Status:** Periodic
- **Interval:** Every 10 minutes
- **Function:** Scans for systemd services, crontab, autostart, startup scripts

### 6. Router Guard Spawner
- **Status:** Continuous
- **Interval:** Spawns every 30 seconds
- **Max Guards:** 10 guards running at once
- **Function:** Constant stream of router guards to defend and clear the router
- **Router Clearing:** Clears router every 10 minutes (kills old guards, spawns fresh ones)
- **Auto-restart:** Yes (if stopped)

### 7. Network Proxy
- **Status:** Continuous
- **Host:** 127.0.0.1
- **Port:** 8080
- **Function:** Network proxy for defense systems
- **Features:**
  - Whitelist/blacklist support
  - Connection logging
  - Threat blocking
- **Auto-restart:** Yes (if stopped)

---

## USAGE

### Start the Factory

```bash
cd /home/anthony/Keepers_room
./organized/scripts/automation/START_AUTOMATED_FACTORY.sh
```

Or manually:

```bash
python3 organized/scripts/automation/AUTOMATED_FACTORY.py --daemon
```

### Check Status

```bash
./organized/scripts/automation/CHECK_FACTORY_STATUS.sh
```

Or manually:

```bash
# View status file
cat /tmp/automated_factory_status.json

# View logs
tail -f /tmp/automated_factory.log
```

### Stop the Factory

```bash
./organized/scripts/automation/STOP_AUTOMATED_FACTORY.sh
```

Or manually:

```bash
# Find PID
cat /tmp/automated_factory.pid

# Kill process
kill $(cat /tmp/automated_factory.pid)
```

---

## FILES

### Scripts
- `organized/scripts/automation/AUTOMATED_FACTORY.py` - Main factory script
- `organized/scripts/automation/START_AUTOMATED_FACTORY.sh` - Start script
- `organized/scripts/automation/STOP_AUTOMATED_FACTORY.sh` - Stop script
- `organized/scripts/automation/CHECK_FACTORY_STATUS.sh` - Status checker

### Logs and Status
- `/tmp/automated_factory.log` - Factory log file
- `/tmp/automated_factory_status.json` - Factory status (JSON)
- `/tmp/automated_factory.pid` - Factory process ID

### Defense System Logs
- `/tmp/recon_flyers.log` - Recon flyers log
- `/tmp/recon_threats.log` - Threat log
- `/tmp/the_dragon.log` - THE DRAGON log
- `/tmp/dragon_kills.log` - THE DRAGON kills log
- `/tmp/the_bombers.log` - THE BOMBERS log
- `/tmp/bomber_strikes.log` - THE BOMBERS strikes log
- `/tmp/persistence_detector.log` - Persistence detector log

---

## CONFIGURATION

Edit `AUTOMATED_FACTORY.py` to change intervals:

```python
RECON_INTERVAL = 30  # Roving recon every 30 seconds
DEEP_SCAN_INTERVAL = 300  # Deep scan every 5 minutes
PUPPY_SWARM_INTERVAL = 60  # Release puppy swarm every 60 seconds
PUPPY_SWARM_COUNT = 3  # Number of puppies per swarm
SPACE_MARINE_CHECK_INTERVAL = 10  # Check space marines every 10 seconds
```

---

## MONITORING

### View Real-Time Logs

```bash
tail -f /tmp/automated_factory.log
```

### View Status

```bash
cat /tmp/automated_factory_status.json | python3 -m json.tool
```

### Check All Defense Systems

```bash
# Check recon flyers
ps aux | grep RECON_FLYERS

# Check THE DRAGON
ps aux | grep THE_DRAGON

# Check THE BOMBERS
ps aux | grep THE_BOMBERS

# Check continuous puppies
ps aux | grep continuous_puppy
```

---

## TROUBLESHOOTING

### Factory Won't Start

1. Check Python3 is installed:
   ```bash
   python3 --version
   ```

2. Check script permissions:
   ```bash
   chmod +x organized/scripts/automation/AUTOMATED_FACTORY.py
   ```

3. Check logs:
   ```bash
   tail -f /tmp/automated_factory.log
   ```

### Factory Stops Unexpectedly

1. Check status:
   ```bash
   ./organized/scripts/automation/CHECK_FACTORY_STATUS.sh
   ```

2. Check logs for errors:
   ```bash
   grep ERROR /tmp/automated_factory.log
   ```

3. Restart factory:
   ```bash
   ./organized/scripts/automation/STOP_AUTOMATED_FACTORY.sh
   ./organized/scripts/automation/START_AUTOMATED_FACTORY.sh
   ```

### Defense Systems Not Starting

1. Check if defense scripts exist:
   ```bash
   ls -la organized/python_agents/RECON_FLYERS.py
   ls -la organized/scripts/utilities/THE_DRAGON.py
   ls -la organized/python_agents/THE_BOMBERS.py
   ```

2. Check if they're executable:
   ```bash
   chmod +x organized/python_agents/RECON_FLYERS.py
   chmod +x organized/scripts/utilities/THE_DRAGON.py
   chmod +x organized/python_agents/THE_BOMBERS.py
   ```

3. Test manually:
   ```bash
   python3 organized/python_agents/RECON_FLYERS.py --quick
   ```

---

## FEATURES

### Auto-Restart
- All defense systems auto-restart if they stop
- Factory monitors and restarts them automatically

### Continuous Operations
- Roving recon flyers run continuously
- Space marines monitor continuously
- Deep scans and puppy swarms run periodically

### Status Reporting
- Real-time status in JSON format
- Detailed logs for all operations
- Activity counters (deep scans, puppy swarms, etc.)

### Daemon Mode
- Runs in background
- PID file for process management
- Logs to `/tmp/automated_factory.log`

---

## SUMMARY

The Automated Factory provides **24/7 continuous defense operations**:

✅ **Roving Recon** - Continuous threat detection  
✅ **Deep Scans** - Periodic comprehensive scans  
✅ **Space Marines** - Ready to eliminate threats  
✅ **Puppy Swarms** - Continuous monitoring agents  
✅ **Persistence Detection** - Periodic scans for persistence  
✅ **Router Guards** - Constant stream of network defenders  
✅ **Network Proxy** - Proxy for defense systems (127.0.0.1:8080)  

**The factory is always watching, always ready, always defending.**

---

**By: Vulcan (The Forge)**  
**For: Anthony Eric Chavez - The Keeper**  
**Date: 2025-11-07**

