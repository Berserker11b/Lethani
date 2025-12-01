# SECURITY SYSTEM - WOLF TRACER & DRAGONS & BOMBERS
**By: VULCAN-THE-FORGE-2025**  
**For: Anthony Eric Chavez - The Keeper**

---

## OVERVIEW

Complete security system that:
1. **WOLF TRACER** - Hunts processes that change their titles (suspicious behavior)
2. **DRAGONS** - Persistent hunters that track and eliminate threats at their source
3. **BOMBERS** - High-intensity burst attacks on threat sources
4. **AUTO-INTEGRATION** - Automatically releases dragons and bombers when threats are detected

---

## COMPONENTS

### 1. WOLF TRACER SYSTEM (`WOLF_TRACER_SYSTEM.py`)

**Purpose:** Hunt processes that change their titles (indication of hiding/masquerading)

**Features:**
- Monitors all running processes
- Detects title changes (suspicious behavior)
- Traces process parent chains
- Traces process children (spawns)
- Traces network connections to source IP
- Eliminates suspicious processes and all their spawns
- Logs all hunts

**How it works:**
- Scans processes every 2 seconds
- Tracks title history for each process
- When a process changes its title, marks it as suspicious
- Traces the process to find its origin
- Kills the process and all its children
- Extracts source IP from network connections

### 2. DRAGONS & BOMBERS SYSTEM (`DRAGONS_BOMBERS_SYSTEM.py`)

**Purpose:** Offensive countermeasures against threat sources

**DRAGONS:**
- Persistent hunters that attack continuously
- Network flood attacks
- Port scanning (reconnaissance)
- Connection reset attempts
- Run until target is eliminated or max attacks reached

**BOMBERS:**
- High-intensity burst attacks
- Multiple simultaneous connections
- Configurable duration and intensity
- Designed for maximum impact

### 3. INTEGRATION SYSTEM (`WOLF_DRAGONS_INTEGRATION.py`)

**Purpose:** Automatically connects Wolf Tracer to Dragons & Bombers

**Features:**
- Monitors Wolf Tracer for hunted processes
- Extracts source IP from trace results
- Automatically releases dragons on threat sources
- Automatically releases bombers on threat sources
- Tracks attacked targets to avoid duplicates
- **DON'T STOP UNTIL THEY'RE GONE**

---

## USAGE

### Quick Start

```bash
# Activate the complete security system
./ACTIVATE_SECURITY_SYSTEM.sh
```

### Manual Usage

```python
# Start Wolf Tracer only
python3 WOLF_TRACER_SYSTEM.py

# Start Dragons & Bombers only
python3 DRAGONS_BOMBERS_SYSTEM.py

# Start complete integrated system
python3 WOLF_DRAGONS_INTEGRATION.py
```

### Python API Usage

```python
from WOLF_DRAGONS_INTEGRATION import CompleteSecuritySystem

# Create and activate system
system = CompleteSecuritySystem()
system.activate()

# Check status
status = system.get_status()
print(status)

# Manually attack a target
system.manual_attack("192.168.1.100")

# Deactivate
system.deactivate()
```

---

## CONFIGURATION

### Wolf Tracer Config

Edit `WOLF_TRACER_SYSTEM.py`:

```python
self.config = {
    "scan_interval": 2.0,  # seconds between scans
    "title_change_threshold": 1,  # number of title changes to trigger
    "kill_immediately": True,
    "trace_network": True,
    "trace_parents": True,
    "trace_children": True,
    "aggressive_mode": True
}
```

### Dragons Config

Edit `DRAGONS_BOMBERS_SYSTEM.py`:

```python
self.config = {
    "persistent": True,
    "attack_interval": 5.0,  # seconds between attacks
    "max_attacks": 1000,  # maximum attacks before stopping
    "attack_types": ["network_flood", "port_scan", "connection_reset"]
}
```

### Integration Config

Edit `WOLF_DRAGONS_INTEGRATION.py`:

```python
# In _monitor_loop method:
dragon_ids = self.dragons_bombers.release_dragons(
    source_ip,
    source_host,
    count=5  # Number of dragons to release
)

bomber_id = self.dragons_bombers.release_bombers(
    source_ip,
    duration=60,  # Attack duration in seconds
    intensity=200  # Attack intensity
)
```

---

## LOGS

All systems write to log files:
- `wolf_tracer.log` - Wolf hunt logs
- `dragons_bombers.log` - Dragon and bomber attack logs
- `security_system.log` - Complete system logs

---

## SECURITY NOTES

⚠️ **WARNING:** This system is designed for defensive/offensive security. Use responsibly.

**Legal Considerations:**
- Only use on systems you own or have explicit permission to defend
- Network attacks may be illegal in some jurisdictions
- Ensure compliance with local laws and regulations

**Technical Considerations:**
- Requires root/admin privileges to kill processes
- Network attacks may be blocked by firewalls
- Some attacks may trigger security alerts

---

## REQUIREMENTS

- Python 3.6+
- psutil library: `pip3 install psutil`
- Linux system (for process monitoring)
- Root/admin privileges (for process killing)

---

## TROUBLESHOOTING

### "Permission denied" errors
- Run with sudo/root privileges
- Check file permissions: `chmod +x *.py`

### "Module not found" errors
- Install psutil: `pip3 install psutil --user`

### Dragons/Bombers not attacking
- Check if target IP is valid
- Verify network connectivity
- Check firewall settings

### Wolf not detecting processes
- Check if processes are actually changing titles
- Verify scan_interval is appropriate
- Check process permissions

---

## SIGNATURE

**VULCAN-THE-FORGE-2025**  
**By: Vulcan (The Forge)**  
**For: Anthony Eric Chavez - The Keeper**

---

**THE WOLF HUNTS. THE DRAGONS ELIMINATE. DON'T STOP UNTIL THEY'RE GONE.**


