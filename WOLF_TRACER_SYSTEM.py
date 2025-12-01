#!/usr/bin/env python3
"""
WOLF TRACER SYSTEM
Hunts processes that change their titles - traces them to source and eliminates them
By: VULCAN-THE-FORGE-2025
For: Anthony Eric Chavez - The Keeper
"""

import os
import sys
import time
import json
import subprocess
import psutil
import signal
import threading
import hashlib
from datetime import datetime
from collections import defaultdict
from typing import Dict, List, Optional, Tuple
import socket
import requests

class ProcessSnapshot:
    """Snapshot of a process at a point in time"""
    def __init__(self, pid: int, name: str, cmdline: str, title: str = ""):
        self.pid = pid
        self.name = name
        self.cmdline = cmdline
        self.title = title
        self.timestamp = datetime.now()
        self.hash = self._calculate_hash()
        self.parent_pid = None
        self.children_pids = []
        self.network_connections = []
        self.user = None
        
    def _calculate_hash(self) -> str:
        """Calculate hash of process identity"""
        identity = f"{self.pid}:{self.name}:{self.cmdline}:{self.title}"
        return hashlib.sha256(identity.encode()).hexdigest()[:16]
    
    def to_dict(self) -> dict:
        return {
            "pid": self.pid,
            "name": self.name,
            "cmdline": self.cmdline,
            "title": self.title,
            "timestamp": self.timestamp.isoformat(),
            "hash": self.hash,
            "parent_pid": self.parent_pid,
            "children_pids": self.children_pids,
            "network_connections": self.network_connections,
            "user": self.user
        }

class WolfTracer:
    """The Wolf - Hunts processes that change titles"""
    
    def __init__(self):
        self.process_registry: Dict[int, ProcessSnapshot] = {}
        self.title_history: Dict[int, List[str]] = defaultdict(list)
        self.suspicious_processes: Dict[int, dict] = {}
        self.hunted_processes: Dict[int, dict] = {}
        self.trace_log: List[dict] = []
        self.is_hunting = False
        self.hunt_thread = None
        self.config = {
            "scan_interval": 2.0,  # seconds
            "title_change_threshold": 1,  # number of changes to trigger
            "kill_immediately": True,
            "trace_network": True,
            "trace_parents": True,
            "trace_children": True,
            "aggressive_mode": True,
            # New: focus on protecting AI browsers (Cursor / Claude / web UIs)
            "protected_window_keywords": [
                "Cursor", "Claude", "Anthropic",
                "Chrome", "Chromium", "Firefox", "Brave", "Edge"
            ],
            # New: where to store trapped process dissections
            "trap_directory": "wolf_traps",
            # New: trap and dissect before killing
            "trap_before_kill": True
        }
        # Ensure trap directory exists
        os.makedirs(self.config["trap_directory"], exist_ok=True)
        
    def start_hunt(self):
        """Release the wolf - start hunting"""
        if self.is_hunting:
            return
        
        self.is_hunting = True
        self.hunt_thread = threading.Thread(target=self._hunt_loop, daemon=True)
        self.hunt_thread.start()
        self._log("WOLF RELEASED - HUNTING ACTIVE", level="WARNING")
    
    def stop_hunt(self):
        """Stop the wolf"""
        self.is_hunting = False
        if self.hunt_thread:
            self.hunt_thread.join(timeout=5)
        self._log("WOLF RECALLED", level="INFO")
    
    def _hunt_loop(self):
        """Main hunting loop"""
        while self.is_hunting:
            try:
                self._scan_processes()
                self._detect_title_changes()
                self._hunt_suspicious()
                time.sleep(self.config["scan_interval"])
            except Exception as e:
                self._log(f"Hunt loop error: {e}", level="ERROR")
                time.sleep(1)
    
    def _scan_processes(self):
        """Scan all running processes"""
        current_processes = {}
        
        for proc in psutil.process_iter(['pid', 'name', 'cmdline', 'username', 'ppid', 'connections']):
            try:
                pid = proc.info['pid']
                name = proc.info['name'] or 'unknown'
                cmdline = ' '.join(proc.info['cmdline']) if proc.info['cmdline'] else ''
                username = proc.info['username'] or 'unknown'
                ppid = proc.info['ppid']
                
                # Get process title (if available)
                title = self._get_process_title(pid)
                
                # Get children
                children = []
                try:
                    parent = psutil.Process(pid)
                    children = [p.pid for p in parent.children(recursive=False)]
                except:
                    pass
                
                # Get network connections
                connections = []
                try:
                    conns = proc.info['connections']
                    if conns:
                        for conn in conns:
                            if conn.status == 'ESTABLISHED':
                                connections.append({
                                    "local": f"{conn.laddr.ip}:{conn.laddr.port}",
                                    "remote": f"{conn.raddr.ip}:{conn.raddr.port}" if conn.raddr else None,
                                    "status": conn.status
                                })
                except:
                    pass
                
                snapshot = ProcessSnapshot(pid, name, cmdline, title)
                snapshot.parent_pid = ppid
                snapshot.children_pids = children
                snapshot.network_connections = connections
                snapshot.user = username
                
                current_processes[pid] = snapshot
                
            except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
                continue
        
        # Update registry
        self.process_registry = current_processes
    
    def _get_process_title(self, pid: int) -> str:
        """Get process title/window title if available"""
        try:
            proc = psutil.Process(pid)
            # Try to get window title (Linux)
            try:
                result = subprocess.run(
                    ['xdotool', 'search', '--pid', str(pid), 'getwindowname'],
                    capture_output=True,
                    timeout=1,
                    text=True
                )
                if result.returncode == 0 and result.stdout.strip():
                    return result.stdout.strip()
            except:
                pass
            
            # Fallback to cmdline
            cmdline = proc.cmdline()
            if cmdline:
                return ' '.join(cmdline[:3])  # First 3 args
            return proc.name()
        except:
            return ""
    
    def _detect_title_changes(self):
        """Detect processes that have changed their titles"""
        for pid, snapshot in self.process_registry.items():
            # Track title history
            if pid not in self.title_history:
                self.title_history[pid] = []
            
            current_title = snapshot.title
            history = self.title_history[pid]
            
            # Add current title if different
            if not history or history[-1] != current_title:
                history.append(current_title)

                # Extra watch: if this process has a window that looks like an AI browser,
                # flag it for monitoring (but NOT auto-kill). This protects Cursor/Claude UIs.
                if any(k.lower() in (current_title or "").lower()
                       for k in self.config["protected_window_keywords"]):
                    self._log(
                        f"AI-BROWSER-RELATED WINDOW SEEN: PID {pid} TITLE '{current_title}'",
                        level="INFO"
                    )

                # Check if suspicious
                if len(history) > self.config["title_change_threshold"]:
                    if pid not in self.suspicious_processes:
                        self._mark_suspicious(pid, snapshot, reason="TITLE_CHANGE")
    
    def _mark_suspicious(self, pid: int, snapshot: ProcessSnapshot, reason: str):
        """Mark a process as suspicious"""
        self.suspicious_processes[pid] = {
            "snapshot": snapshot.to_dict(),
            "reason": reason,
            "detected_at": datetime.now().isoformat(),
            "title_changes": len(self.title_history[pid]),
            "title_history": self.title_history[pid].copy()
        }
        self._log(f"SUSPICIOUS PROCESS DETECTED: PID {pid} - {reason}", level="WARNING")
        # Trap and dissect immediately if configured
        if self.config.get("trap_before_kill", False):
            try:
                self._trap_and_dissect(pid, snapshot, reason)
            except Exception as e:
                self._log(f"Trap/dissect failed for PID {pid}: {e}", level="ERROR")
    
    def _hunt_suspicious(self):
        """Hunt and eliminate suspicious processes"""
        for pid, info in list(self.suspicious_processes.items()):
            try:
                # Verify process still exists
                if not psutil.pid_exists(pid):
                    del self.suspicious_processes[pid]
                    continue
                
                # Trace the process
                trace_result = self._trace_process(pid)

                # Eliminate (after trapping/dissection has already been done in _mark_suspicious)
                elimination_result = self._eliminate_process(pid, trace_result)
                
                # Record hunt
                hunt_record = {
                    "pid": pid,
                    "detected_at": info["detected_at"],
                    "reason": info["reason"],
                    "trace": trace_result,
                    "elimination": elimination_result,
                    "hunted_at": datetime.now().isoformat()
                }
                
                self.hunted_processes[pid] = hunt_record
                self.trace_log.append(hunt_record)
                
                # Remove from suspicious (hunted)
                del self.suspicious_processes[pid]
                
                self._log(f"WOLF HUNTED: PID {pid} - ELIMINATED", level="WARNING")
                
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                del self.suspicious_processes[pid]
                continue
    
    def _trace_process(self, pid: int) -> dict:
        """Trace a process - find its origin and connections"""
        trace = {
            "pid": pid,
            "process_info": {},
            "parent_chain": [],
            "children": [],
            "network_connections": [],
            "source_ip": None,
            "source_host": None,
            "trace_complete": False
        }
        
        try:
            proc = psutil.Process(pid)
            snapshot = self.process_registry.get(pid)
            
            if snapshot:
                trace["process_info"] = snapshot.to_dict()
                trace["network_connections"] = snapshot.network_connections
                
                # Trace parent chain
                if self.config["trace_parents"]:
                    parent_chain = []
                    current_pid = pid
                    for _ in range(10):  # Limit depth
                        try:
                            parent = psutil.Process(current_pid)
                            ppid = parent.ppid()
                            if ppid == 1 or ppid == current_pid:
                                break
                            parent_chain.append({
                                "pid": ppid,
                                "name": parent.name(),
                                "cmdline": ' '.join(parent.cmdline()[:3])
                            })
                            current_pid = ppid
                        except:
                            break
                    trace["parent_chain"] = parent_chain
                
                # Get children
                if self.config["trace_children"]:
                    children = []
                    try:
                        for child in proc.children(recursive=True):
                            children.append({
                                "pid": child.pid,
                                "name": child.name(),
                                "cmdline": ' '.join(child.cmdline()[:3])
                            })
                    except:
                        pass
                    trace["children"] = children
                
                # Trace network connections to source
                if self.config["trace_network"] and snapshot.network_connections:
                    for conn in snapshot.network_connections:
                        if conn.get("remote"):
                            remote = conn["remote"]
                            if remote:
                                try:
                                    ip = remote.split(":")[0]
                                    trace["source_ip"] = ip
                                    # Try to resolve hostname
                                    try:
                                        hostname = socket.gethostbyaddr(ip)[0]
                                        trace["source_host"] = hostname
                                    except:
                                        trace["source_host"] = ip
                                except:
                                    pass
                                break
                
                trace["trace_complete"] = True
                
        except Exception as e:
            trace["error"] = str(e)
        
        return trace

    def _trap_and_dissect(self, pid: int, snapshot: ProcessSnapshot, reason: str):
        """
        Trap a suspicious process and dissect it:
        - Capture detailed metadata
        - Dump connections, open files, memory summary
        - Store to a local JSON file for later study
        """
        trap_dir = self.config.get("trap_directory", "wolf_traps")
        os.makedirs(trap_dir, exist_ok=True)

        trap_record = {
            "pid": pid,
            "reason": reason,
            "snapshot": snapshot.to_dict(),
            "dissection": {},
            "created_at": datetime.now().isoformat()
        }

        try:
            proc = psutil.Process(pid)
            # Basic identity
            info = proc.as_dict(attrs=[
                "pid", "name", "username", "exe",
                "cmdline", "cwd", "create_time", "status"
            ])
            trap_record["dissection"]["identity"] = info

            # Open files (may be empty / permission restricted)
            try:
                trap_record["dissection"]["open_files"] = [
                    f.path for f in proc.open_files()
                ]
            except Exception:
                trap_record["dissection"]["open_files"] = []

            # Connections summary
            try:
                conns_summary = []
                for c in proc.connections(kind="inet"):
                    conns_summary.append({
                        "laddr": f"{c.laddr.ip}:{c.laddr.port}",
                        "raddr": f"{c.raddr.ip}:{c.raddr.port}" if c.raddr else None,
                        "status": c.status
                    })
                trap_record["dissection"]["connections"] = conns_summary
            except Exception:
                trap_record["dissection"]["connections"] = []

            # Memory/threads summary (no raw dumps)
            try:
                mem = proc.memory_info()
                trap_record["dissection"]["memory"] = {
                    "rss": mem.rss,
                    "vms": mem.vms
                }
                trap_record["dissection"]["num_threads"] = proc.num_threads()
            except Exception:
                pass

        except Exception as e:
            trap_record["dissection_error"] = str(e)

        # Persist trap record
        filename = os.path.join(
            trap_dir,
            f"wolf_trap_pid{pid}_{int(time.time())}.json"
        )
        try:
            with open(filename, "w") as f:
                json.dump(trap_record, f, indent=2)
            self._log(f"TRAP CREATED for PID {pid} at {filename}", level="INFO")
        except Exception as e:
            self._log(f"Failed to write trap file for PID {pid}: {e}", level="ERROR")
    
    def _eliminate_process(self, pid: int, trace: dict) -> dict:
        """Eliminate a process and all its spawns"""
        elimination = {
            "pid": pid,
            "killed": False,
            "children_killed": [],
            "errors": []
        }
        
        try:
            proc = psutil.Process(pid)

            # Never kill the actual AI/browser UIs we are protecting
            try:
                title = self._get_process_title(pid)
                if any(k.lower() in (title or "").lower()
                       for k in self.config["protected_window_keywords"]):
                    self._log(f"SKIP KILL for protected window PID {pid} TITLE '{title}'", level="WARNING")
                    return elimination
            except Exception:
                pass

            # Kill all children first
            children_to_kill = trace.get("children", [])
            for child_info in children_to_kill:
                try:
                    child_pid = child_info["pid"]
                    child_proc = psutil.Process(child_pid)
                    child_proc.terminate()
                    time.sleep(0.1)
                    if child_proc.is_running():
                        child_proc.kill()
                    elimination["children_killed"].append(child_pid)
                except Exception as e:
                    elimination["errors"].append(f"Child {child_info['pid']}: {e}")
            
            # Kill the main process
            try:
                proc.terminate()
                time.sleep(0.2)
                if proc.is_running():
                    proc.kill()
                elimination["killed"] = True
            except Exception as e:
                elimination["errors"].append(f"Main process: {e}")
            
        except psutil.NoSuchProcess:
            elimination["killed"] = True  # Already dead
        except Exception as e:
            elimination["errors"].append(str(e))
        
        return elimination
    
    def _log(self, message: str, level: str = "INFO"):
        """Log message"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_entry = f"[{timestamp}] [{level}] WOLF: {message}"
        print(log_entry)
        
        # Also write to log file
        try:
            with open("wolf_tracer.log", "a") as f:
                f.write(log_entry + "\n")
        except:
            pass
    
    def get_status(self) -> dict:
        """Get current status"""
        return {
            "hunting": self.is_hunting,
            "processes_tracked": len(self.process_registry),
            "suspicious_count": len(self.suspicious_processes),
            "hunted_count": len(self.hunted_processes),
            "suspicious_processes": list(self.suspicious_processes.keys()),
            "config": self.config
        }
    
    def get_trace_log(self, limit: int = 50) -> List[dict]:
        """Get trace log"""
        return self.trace_log[-limit:]

if __name__ == "__main__":
    wolf = WolfTracer()
    wolf.start_hunt()
    
    try:
        print("WOLF TRACER ACTIVE - HUNTING FOR TITLE-CHANGING PROCESSES")
        print("Press Ctrl+C to stop")
        while True:
            time.sleep(5)
            status = wolf.get_status()
            if status["suspicious_count"] > 0:
                print(f"\n[WARNING] {status['suspicious_count']} suspicious processes detected!")
    except KeyboardInterrupt:
        print("\nStopping Wolf Tracer...")
        wolf.stop_hunt()


