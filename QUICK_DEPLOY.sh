#!/bin/bash
# ══════════════════════════════════════════════════════════════
# QUICK DEPLOY - Deploy All Systems with Quick Keys
# ══════════════════════════════════════════════════════════════
# CREATOR SIGNATURE
# ══════════════════════════════════════════════════════════════
# By: Auto - AI Agent Router (Cursor)
# For: Anthony Eric Chavez - The Keeper
# Date: 2025-11-08
# Signature: AUTO-QUICK-DEPLOY-20251108-V1.0
# DNA: chavez-jackal7-family
# ══════════════════════════════════════════════════════════════

KEEPERS_ROOM="/home/anthony/Keepers_room"
cd "$KEEPERS_ROOM"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to deploy system
deploy_system() {
    local name=$1
    local command=$2
    local pid_file=$3
    
    echo -e "${YELLOW}Deploying $name...${NC}"
    eval "$command" > /tmp/${name,,}_deploy.log 2>&1 &
    local pid=$!
    echo "$pid" > "$pid_file" 2>/dev/null
    sleep 1
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${GREEN}✅ $name deployed (PID: $pid)${NC}"
    else
        echo -e "${RED}❌ $name deployment may have failed${NC}"
    fi
}

# Main deployment menu
case "${1:-all}" in
    "all"|"a")
        echo "══════════════════════════════════════════════════════════════"
        echo "DEPLOYING ALL SYSTEMS"
        echo "══════════════════════════════════════════════════════════════"
        echo ""
        
        # 1. Full Sweep Scan
        deploy_system "Full_Sweep_Scan" "bash FULL_SWEEP_DEEP_SCAN.sh" "/tmp/full_sweep.pid"
        
        # 2. Continuous Puppy
        deploy_system "Continuous_Puppy" "python3 continuous_puppy.py start" "/tmp/continuous_puppy.pid"
        
        # 3. Swarms
        deploy_system "Swarms" "bash organized/scripts/deployment/LAUNCH_SWARMS_AND_FIND.sh" "/tmp/swarms.pid"
        
        # 4. Router Fortress Agents
        deploy_system "Router_Fortress" "python3 ROUTER_FORTRESS_AGENT.py" "/tmp/router_fortress.pid"
        
        # 5. Gatling Projectile Injectors
        deploy_system "Gatling_Injector" "python3 GATLING_PROJECTILE_INJECTOR.py" "/tmp/gatling_injector.pid"
        
        # 6. Automated Agent Factory
        deploy_system "Automated_Factory" "python3 AUTOMATED_AGENT_FACTORY.py" "/tmp/automated_factory.pid"
        
        # 7. Router Guards
        deploy_system "Router_Guards" "python3 ROUTER_GUARDS.py" "/tmp/router_guards.pid"
        
        # 8. Continuous Spawner
        deploy_system "Continuous_Spawner" "bash agents/continuous_spawner.sh" "/tmp/continuous_spawner.pid"
        
        # 9. Signature Radar
        deploy_system "Signature_Radar" "python3 SIGNATURE_RADAR.py" "/tmp/signature_radar.pid"
        
        # 10. Cross Device Scanner
        deploy_system "Cross_Device_Scanner" "python3 CROSS_DEVICE_SCANNER.py" "/tmp/cross_device_scanner.pid"
        
        echo ""
        echo "══════════════════════════════════════════════════════════════"
        echo "ALL SYSTEMS DEPLOYED"
        echo "══════════════════════════════════════════════════════════════"
        ;;
    
    "scan"|"s")
        echo "Deploying Full Sweep Scan..."
        deploy_system "Full_Sweep_Scan" "bash FULL_SWEEP_DEEP_SCAN.sh" "/tmp/full_sweep.pid"
        ;;
    
    "puppy"|"p")
        echo "Deploying Continuous Puppy..."
        deploy_system "Continuous_Puppy" "python3 continuous_puppy.py start" "/tmp/continuous_puppy.pid"
        ;;
    
    "swarms"|"sw")
        echo "Deploying Swarms..."
        deploy_system "Swarms" "bash organized/scripts/deployment/LAUNCH_SWARMS_AND_FIND.sh" "/tmp/swarms.pid"
        ;;
    
    "fortress"|"f")
        echo "Deploying Router Fortress..."
        deploy_system "Router_Fortress" "python3 ROUTER_FORTRESS_AGENT.py" "/tmp/router_fortress.pid"
        ;;
    
    "gatling"|"g")
        echo "Deploying Gatling Injector..."
        deploy_system "Gatling_Injector" "python3 GATLING_PROJECTILE_INJECTOR.py" "/tmp/gatling_injector.pid"
        ;;
    
    "factory"|"fa")
        echo "Deploying Automated Factory..."
        deploy_system "Automated_Factory" "python3 AUTOMATED_AGENT_FACTORY.py" "/tmp/automated_factory.pid"
        ;;
    
    "guards"|"gu")
        echo "Deploying Router Guards..."
        deploy_system "Router_Guards" "python3 ROUTER_GUARDS.py" "/tmp/router_guards.pid"
        ;;
    
    "spawner"|"sp")
        echo "Deploying Continuous Spawner..."
        deploy_system "Continuous_Spawner" "bash agents/continuous_spawner.sh" "/tmp/continuous_spawner.pid"
        ;;
    
    "radar"|"r")
        echo "Deploying Signature Radar..."
        deploy_system "Signature_Radar" "python3 SIGNATURE_RADAR.py" "/tmp/signature_radar.pid"
        ;;
    
    "scanner"|"sc")
        echo "Deploying Cross Device Scanner..."
        deploy_system "Cross_Device_Scanner" "python3 CROSS_DEVICE_SCANNER.py" "/tmp/cross_device_scanner.pid"
        ;;
    
    "defense"|"d")
        echo "Deploying Defense Systems..."
        deploy_system "Router_Fortress" "python3 ROUTER_FORTRESS_AGENT.py" "/tmp/router_fortress.pid"
        deploy_system "Router_Guards" "python3 ROUTER_GUARDS.py" "/tmp/router_guards.pid"
        deploy_system "Signature_Radar" "python3 SIGNATURE_RADAR.py" "/tmp/signature_radar.pid"
        deploy_system "Cross_Device_Scanner" "python3 CROSS_DEVICE_SCANNER.py" "/tmp/cross_device_scanner.pid"
        ;;
    
    "offense"|"o")
        echo "Deploying Offense Systems..."
        deploy_system "Gatling_Injector" "python3 GATLING_PROJECTILE_INJECTOR.py" "/tmp/gatling_injector.pid"
        deploy_system "Swarms" "bash organized/scripts/deployment/LAUNCH_SWARMS_AND_FIND.sh" "/tmp/swarms.pid"
        ;;
    
    "monitoring"|"m")
        echo "Deploying Monitoring Systems..."
        deploy_system "Full_Sweep_Scan" "bash FULL_SWEEP_DEEP_SCAN.sh" "/tmp/full_sweep.pid"
        deploy_system "Continuous_Puppy" "python3 continuous_puppy.py start" "/tmp/continuous_puppy.pid"
        deploy_system "Signature_Radar" "python3 SIGNATURE_RADAR.py" "/tmp/signature_radar.pid"
        ;;
    
    "help"|"h"|"-h"|"--help")
        echo "══════════════════════════════════════════════════════════════"
        echo "QUICK DEPLOY - USAGE"
        echo "══════════════════════════════════════════════════════════════"
        echo ""
        echo "Usage: bash QUICK_DEPLOY.sh [key]"
        echo ""
        echo "Quick Keys:"
        echo "  all, a          - Deploy all systems"
        echo "  scan, s         - Full sweep scan"
        echo "  puppy, p        - Continuous puppy"
        echo "  swarms, sw      - Deploy swarms"
        echo "  fortress, f     - Router fortress agents"
        echo "  gatling, g      - Gatling projectile injectors"
        echo "  factory, fa     - Automated agent factory"
        echo "  guards, gu      - Router guards"
        echo "  spawner, sp     - Continuous spawner"
        echo "  radar, r        - Signature radar"
        echo "  scanner, sc     - Cross device scanner"
        echo "  defense, d      - All defense systems"
        echo "  offense, o      - All offense systems"
        echo "  monitoring, m   - All monitoring systems"
        echo "  help, h         - Show this help"
        echo ""
        echo "Examples:"
        echo "  bash QUICK_DEPLOY.sh all      # Deploy everything"
        echo "  bash QUICK_DEPLOY.sh scan     # Just full sweep"
        echo "  bash QUICK_DEPLOY.sh defense  # All defense systems"
        echo ""
        ;;
    
    *)
        echo "Unknown key: $1"
        echo "Use 'bash QUICK_DEPLOY.sh help' for usage"
        exit 1
        ;;
esac

