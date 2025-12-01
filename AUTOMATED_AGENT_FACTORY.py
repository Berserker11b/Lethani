#!/usr/bin/env python3
"""
AUTOMATED AGENT FACTORY - Automated Agent Spawning System
Automatically spawns defensive agents for monitoring and protection
By: Vulcan (The Forge)
For: Anthony Eric Chavez - The Keeper
"""

import subprocess
import time
import json
import os
import sys
import threading
from datetime import datetime
from pathlib import Path
import psutil

# ============================================================================
# CONFIGURATION
# ============================================================================

FACTORY_LOG = "/tmp/agent_factory.log"
AGENT_STATUS_FILE = "/tmp/agent_factory_status.json"
AGENT_DIR = Path("/tmp/agent_factory_agents")
AGENT_DIR.mkdir(exist_ok=True)

# Agent types and configurations
AGENT_TYPES = {
    'deep_scan': {
        'script': 'ENHANCED_DEEP_SCAN_WITH_TRAPS.sh',
        'interval': 120,  # Run every 2 minutes (increased production)
        'max_instances': 5,  # Increased from 2 to 5
        'description': 'Deep scan agent for threat detection'
    },
    'network_monitor': {
        'script': 'ROUTER_GUARDS.py',
        'interval': 0,  # Continuous
        'max_instances': 3,  # Increased from 1 to 3
        'description': 'Network monitoring agent'
    },
    'process_monitor': {
        'script': 'MONSTER_HUNTER.py',
        'interval': 0,  # Continuous
        'max_instances': 2,  # Increased from 1 to 2
        'description': 'Process monitoring agent'
    },
    'threat_monitor': {
        'script': 'continuous_puppy.py',
        'interval': 0,  # Continuous
        'max_instances': 2,  # Increased from 1 to 2
        'description': 'Threat monitoring agent'
    },
    'thermal_guard': {
        'script': 'thermal_guardian.py',
        'interval': 0,  # Continuous
        'max_instances': 1,
        'description': 'Thermal protection agent'
    },
    'router_fortress': {
        'script': 'ROUTER_FORTRESS_AGENT.py',
        'interval': 0,  # Continuous
        'max_instances': 5,  # Multiple fortress agents to hold router
        'description': 'Router fortress agent - hold and defend router'
    },
    'gatling_injector': {
        'script': 'GATLING_PROJECTILE_INJECTOR.py',
        'interval': 0,  # Continuous
        'max_instances': 3,  # Multiple Gatling injectors for rapid fire
        'description': 'Gatling projectile injector - fire and replicate codes'
    }
}

# Active agents tracking
active_agents = {}

# ============================================================================
# AGENT FACTORY FUNCTIONS
# ============================================================================

def log_message(message, level="INFO"):
    """Log message to file"""
    timestamp = datetime.now().isoformat()
    log_entry = f"[{timestamp}] [{level}] {message}\n"
    
    try:
        with open(FACTORY_LOG, 'a') as f:
            f.write(log_entry)
    except Exception as e:
        print(f"Log error: {e}")

def spawn_agent(agent_type, agent_config):
    """Spawn a new agent"""
    script_name = agent_config['script']
    script_path = Path(__file__).parent / script_name
    
    if not script_path.exists():
        log_message(f"Agent script not found: {script_path}", "ERROR")
        return None
    
    try:
        # Determine how to run the script
        if script_path.suffix == '.py':
            cmd = ['python3', str(script_path)]
        elif script_path.suffix == '.sh':
            cmd = ['bash', str(script_path)]
        else:
            log_message(f"Unknown script type: {script_path.suffix}", "ERROR")
            return None
        
        # Spawn agent
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=str(script_path.parent)
        )
        
        agent_id = f"{agent_type}_{process.pid}"
        
        active_agents[agent_id] = {
            'type': agent_type,
            'pid': process.pid,
            'script': script_name,
            'started': datetime.now().isoformat(),
            'process': process,
            'status': 'running'
        }
        
        log_message(f"Spawned agent: {agent_id} (PID: {process.pid}) - {agent_config['description']}", "INFO")
        
        return agent_id
        
    except Exception as e:
        log_message(f"Error spawning agent {agent_type}: {e}", "ERROR")
        return None

def check_agent_health(agent_id, agent_info):
    """Check if agent is still running"""
    try:
        pid = agent_info['pid']
        process = psutil.Process(pid)
        
        if process.is_running():
            return True
        else:
            log_message(f"Agent {agent_id} (PID: {pid}) is not running", "WARNING")
            return False
    except psutil.NoSuchProcess:
        log_message(f"Agent {agent_id} (PID: {agent_info['pid']}) process not found", "WARNING")
        return False
    except Exception as e:
        log_message(f"Error checking agent {agent_id}: {e}", "ERROR")
        return False

def cleanup_dead_agents():
    """Remove dead agents from tracking"""
    dead_agents = []
    
    for agent_id, agent_info in list(active_agents.items()):
        if not check_agent_health(agent_id, agent_info):
            dead_agents.append(agent_id)
            agent_info['status'] = 'dead'
    
    for agent_id in dead_agents:
        del active_agents[agent_id]
        log_message(f"Removed dead agent: {agent_id}", "INFO")
    
    return len(dead_agents)

def maintain_agents():
    """Maintain desired number of agents"""
    for agent_type, agent_config in AGENT_TYPES.items():
        max_instances = agent_config['max_instances']
        
        # Count active agents of this type
        active_count = sum(1 for a in active_agents.values() if a['type'] == agent_type and a['status'] == 'running')
        
        # Spawn more if needed
        if active_count < max_instances:
            needed = max_instances - active_count
            for _ in range(needed):
                agent_id = spawn_agent(agent_type, agent_config)
                if agent_id:
                    log_message(f"Spawned {agent_type} agent: {agent_id}", "INFO")
                time.sleep(1)  # Small delay between spawns

def save_agent_status():
    """Save agent status to file"""
    status = {
        'timestamp': datetime.now().isoformat(),
        'total_agents': len(active_agents),
        'agents': {}
    }
    
    for agent_id, agent_info in active_agents.items():
        status['agents'][agent_id] = {
            'type': agent_info['type'],
            'pid': agent_info['pid'],
            'script': agent_info['script'],
            'started': agent_info['started'],
            'status': agent_info['status']
        }
    
    try:
        with open(AGENT_STATUS_FILE, 'w') as f:
            json.dump(status, f, indent=2)
    except Exception as e:
        log_message(f"Error saving agent status: {e}", "ERROR")

def factory_loop():
    """Main factory loop"""
    log_message("Automated Agent Factory activated", "INFO")
    
    while True:
        try:
            # Cleanup dead agents
            cleanup_dead_agents()
            
            # Maintain desired number of agents
            maintain_agents()
            
            # Save status
            save_agent_status()
            
            # Log status
            log_message(f"Factory status: {len(active_agents)} active agents", "INFO")
            
            time.sleep(30)  # Check every 30 seconds
            
        except KeyboardInterrupt:
            log_message("Agent Factory stopped by user", "INFO")
            break
        except Exception as e:
            log_message(f"Error in factory loop: {e}", "ERROR")
            time.sleep(30)

def get_factory_status():
    """Get factory status"""
    try:
        with open(AGENT_STATUS_FILE, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return {
            'status': 'not_running',
            'timestamp': datetime.now().isoformat()
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e),
            'timestamp': datetime.now().isoformat()
        }

def main():
    """Main function"""
    print("══════════════════════════════════════════════════════════════")
    print("AUTOMATED AGENT FACTORY - Agent Spawning System")
    print("══════════════════════════════════════════════════════════════")
    print("")
    print("By: Vulcan (The Forge)")
    print("For: Anthony Eric Chavez - The Keeper")
    print("")
    print("Starting agent factory...")
    print("")
    
    # Initial spawn of all agents
    log_message("Initial agent spawn", "INFO")
    maintain_agents()
    
    # Start factory loop
    try:
        factory_loop()
    except KeyboardInterrupt:
        print("\nAgent Factory stopped")
        sys.exit(0)

if __name__ == '__main__':
    main()







