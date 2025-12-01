# QUICK KEYS - Deployment Guide
## ══════════════════════════════════════════════════════════════
## CREATOR SIGNATURE
## ══════════════════════════════════════════════════════════════
**By:** Auto - AI Agent Router (Cursor)  
**For:** Anthony Eric Chavez - The Keeper  
**Date:** 2025-11-08  
**Signature:** AUTO-QUICK-KEYS-20251108-V1.0  
**DNA:** chavez-jackal7-family  
## ══════════════════════════════════════════════════════════════

## 🚀 QUICK DEPLOYMENT

### Main Command
```bash
bash QUICK_DEPLOY.sh [key]
```

### Quick Keys

| Key | Full Name | Description |
|-----|-----------|-------------|
| `all` or `a` | All Systems | Deploy everything |
| `scan` or `s` | Full Sweep Scan | Comprehensive system scan |
| `puppy` or `p` | Continuous Puppy | Threat monitoring daemon |
| `swarms` or `sw` | Swarms | Deploy agent swarms |
| `fortress` or `f` | Router Fortress | Router defense agents |
| `gatling` or `g` | Gatling Injector | Code firing system |
| `factory` or `fa` | Automated Factory | Agent factory |
| `guards` or `gu` | Router Guards | Network protection |
| `spawner` or `sp` | Continuous Spawner | Agent spawner |
| `radar` or `r` | Signature Radar | Threat detection |
| `scanner` or `sc` | Cross Device Scanner | USB/device monitoring |
| `defense` or `d` | Defense Systems | All defense systems |
| `offense` or `o` | Offense Systems | All offense systems |
| `monitoring` or `m` | Monitoring Systems | All monitoring systems |

## 📋 EXAMPLES

### Deploy Everything
```bash
bash QUICK_DEPLOY.sh all
```

### Deploy Just Defense
```bash
bash QUICK_DEPLOY.sh defense
```

### Deploy Just Offense
```bash
bash QUICK_DEPLOY.sh offense
```

### Deploy Individual System
```bash
bash QUICK_DEPLOY.sh scan
bash QUICK_DEPLOY.sh gatling
bash QUICK_DEPLOY.sh puppy
```

## 🎯 KEYBOARD SHORTCUTS (Optional)

You can create aliases in your `~/.bashrc`:

```bash
# Add to ~/.bashrc
alias deploy-all='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh all'
alias deploy-scan='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh scan'
alias deploy-puppy='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh puppy'
alias deploy-swarms='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh swarms'
alias deploy-fortress='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh fortress'
alias deploy-gatling='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh gatling'
alias deploy-defense='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh defense'
alias deploy-offense='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh offense'
alias deploy-monitoring='bash /home/anthony/Keepers_room/QUICK_DEPLOY.sh monitoring'
```

Then reload:
```bash
source ~/.bashrc
```

Now you can use:
```bash
deploy-all
deploy-defense
deploy-scan
```

## 📊 STATUS CHECKING

Check what's running:
```bash
ps aux | grep -E "continuous_puppy|ROUTER_FORTRESS|GATLING|AUTOMATED_AGENT_FACTORY" | grep -v grep
```

Check logs:
```bash
tail -f /tmp/continuous_puppy.log
tail -f /tmp/router_fortress.log
tail -f /tmp/gatling_injector.log
```

## 🛑 STOPPING SYSTEMS

Stop all:
```bash
pkill -f "continuous_puppy|ROUTER_FORTRESS|GATLING|AUTOMATED_AGENT_FACTORY|ROUTER_GUARDS"
```

Stop individual:
```bash
pkill -f "continuous_puppy"
pkill -f "ROUTER_FORTRESS"
pkill -f "GATLING_PROJECTILE"
```

