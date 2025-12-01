#!/usr/bin/env python3
"""
KEEPERS ROOM ORGANIZER - Autonomous Organization Agent
Organizes and categorizes all files in the Keeper's Room
By: Organizer Agent - First Circuit
"""

import os
import shutil
import json
from pathlib import Path
from datetime import datetime
from collections import defaultdict
import time

# Base directory
BASE_DIR = Path("/home/anthony/Keepers_room")
ORGANIZED_DIR = BASE_DIR / "organized"
LOG_DIR = BASE_DIR / "organization_logs"
LOG_DIR.mkdir(exist_ok=True)

# Organization structure
ORGANIZATION = {
    "scripts": {
        "dir": "scripts",
        "patterns": [".sh", ".bash"],
        "subdirs": {
            "deployment": ["DEPLOY", "LAUNCH", "START", "RUN", "SPAWN"],
            "protection": ["PROTECT", "DEFENSE", "GUARD", "SHIELD", "SECURE"],
            "monitoring": ["MONITOR", "SCAN", "CHECK", "TRACE", "TRACK"],
            "injection": ["INJECT", "INJECTOR"],
            "activation": ["ACTIVATE", "ENABLE"],
            "elimination": ["KILL", "ELIMINATE", "TARGET", "RAPID"],
            "coordination": ["COORDINATE", "CONNECT", "HOOK", "FIX", "REBUILD"],
            "utilities": ["MAKE", "USE", "OPEN", "FIND", "GO", "TAKE", "WRAP"],
        }
    },
    "python_agents": {
        "dir": "python_agents",
        "patterns": [".py"],
        "subdirs": {
            "monitors": ["MONITOR", "PUPPY", "GUARDIAN", "HUNTER", "TRACER", "ELIMINATOR"],
            "defense": ["DEFENSE", "PROTECTION", "GUARD", "ROUTER"],
            "agents": ["AGENT", "FACTORY", "COMPANION", "ORCHESTRATOR"],
            "utilities": ["COMPRESS", "BOOTSTRAP", "REBUILD"],
        }
    },
    "javascript": {
        "dir": "javascript",
        "patterns": [".js"],
        "subdirs": {
            "wardog": ["WARDOG"],
            "chatbox": ["CHATBOX", "UNIVERSAL"],
            "protection": ["PROTECT", "DEFENSE", "DEATHCODE", "CLIPBOARD"],
            "mirror_worlds": ["MIRROR", "BUS"],
            "gundam": ["GUNDAM", "CONTAINER"],
            "utilities": ["TERMINAL", "SPAWN"],
        }
    },
    "documentation": {
        "dir": "documentation",
        "patterns": [".md", ".txt"],
        "subdirs": {
            "guides": ["GUIDE", "HOW_TO", "QUICK_START", "README"],
            "status": ["STATUS", "SUMMARY", "REPORT"],
            "instructions": ["INSTRUCTIONS", "INFO", "ACCESS"],
            "notes": ["NOTE", "PLAN", "RESEARCH"],
        }
    },
    "compressed": {
        "dir": "compressed",
        "patterns": [".ijc", ".ijca", ".zip"],
    },
    "databases": {
        "dir": "databases",
        "patterns": [".db", ".kdbx"],
    },
    "config": {
        "dir": "config",
        "patterns": [".toml", ".json", ".manifest"],
    },
    "evidence": {
        "dir": "evidence",
        "keep": True,  # Don't move, already organized
    },
    "scans": {
        "dir": "scans",
        "keep": True,  # Don't move, already organized
    },
    "tracking": {
        "dir": "tracking",
        "keep": True,  # Don't move, already organized
    },
    "projects": {
        "dir": "projects",
        "subdirs": {
            "mirror_worlds": ["collapse_conquest", "mirror_worlds"],
            "experiments": ["experiments"],
            "research": ["Researcher", "Gemini", "science"],
        }
    },
    "archives": {
        "dir": "archives",
        "patterns": [".zip", ".deb"],
    },
}

# Files to never move
PROTECTED_FILES = [
    "organize_keepers_room.py",
    "KEEPERS_ROOM_ORGANIZER.py",
    ".git",
    ".gitignore",
    "node_modules",
    "__pycache__",
    "organized",
    "organization_logs",
]

def log_message(message, level="INFO"):
    """Log message with timestamp"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    log_entry = f"[{timestamp}] [{level}] {message}\n"
    log_file = LOG_DIR / f"organizer_{datetime.now().strftime('%Y%m%d')}.log"
    
    with open(log_file, 'a') as f:
        f.write(log_entry)
    print(log_entry.strip())

def should_organize(file_path):
    """Check if file should be organized"""
    name = file_path.name
    
    # Skip protected files
    for protected in PROTECTED_FILES:
        if protected in name or protected in str(file_path):
            return False
    
    # Skip if already in organized structure
    if "organized" in str(file_path) or "organization_logs" in str(file_path):
        return False
    
    return True

def categorize_file(file_path):
    """Categorize a file into organization structure"""
    name = file_path.name.upper()
    suffix = file_path.suffix.lower()
    
    # Check each category
    for cat_name, cat_config in ORGANIZATION.items():
        # Skip if keep flag is set
        if cat_config.get("keep"):
            continue
        
        # Check patterns
        if "patterns" in cat_config:
            if suffix in cat_config["patterns"]:
                # Check subdirs
                if "subdirs" in cat_config:
                    for subdir, keywords in cat_config["subdirs"].items():
                        if any(keyword in name for keyword in keywords):
                            return cat_name, subdir
                return cat_name, None
        
        # Check subdirs for projects
        if "subdirs" in cat_config:
            for subdir, keywords in cat_config["subdirs"].items():
                if any(keyword.lower() in name.lower() for keyword in keywords):
                    return cat_name, subdir
    
    # Default: utilities
    return "scripts", "utilities"

def organize_file(file_path, dry_run=False):
    """Organize a single file"""
    if not should_organize(file_path):
        return None
    
    # Categorize
    category, subdir = categorize_file(file_path)
    cat_config = ORGANIZATION[category]
    
    # Build destination path
    dest_dir = ORGANIZED_DIR / cat_config["dir"]
    if subdir:
        dest_dir = dest_dir / subdir
    dest_dir.mkdir(parents=True, exist_ok=True)
    
    dest_path = dest_dir / file_path.name
    
    # Handle duplicates
    if dest_path.exists():
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        name_parts = file_path.stem, timestamp, file_path.suffix
        dest_path = dest_dir / f"{name_parts[0]}_{name_parts[1]}{name_parts[2]}"
    
    if not dry_run:
        try:
            shutil.move(str(file_path), str(dest_path))
            log_message(f"✅ MOVED: {file_path.name} → {dest_path.relative_to(BASE_DIR)}")
            return str(dest_path.relative_to(BASE_DIR))
        except Exception as e:
            log_message(f"❌ ERROR moving {file_path.name}: {e}", "ERROR")
            return None
    else:
        log_message(f"📋 WOULD MOVE: {file_path.name} → {dest_path.relative_to(BASE_DIR)}")
        return str(dest_path.relative_to(BASE_DIR))

def organize_directory(dry_run=False):
    """Organize all files in the directory"""
    log_message("══════════════════════════════════════════════════════════════")
    log_message("KEEPERS ROOM ORGANIZER - Starting organization")
    log_message("══════════════════════════════════════════════════════════════")
    
    if dry_run:
        log_message("🔍 DRY RUN MODE - No files will be moved")
    
    organized = []
    skipped = []
    errors = []
    
    # Get all files in base directory
    for item in BASE_DIR.iterdir():
        if item.is_file():
            if should_organize(item):
                result = organize_file(item, dry_run)
                if result:
                    organized.append((item.name, result))
                else:
                    errors.append(item.name)
            else:
                skipped.append(item.name)
        elif item.is_dir():
            # Handle directories
            name = item.name.lower()
            
            # Skip protected directories
            if any(protected.lower() in name for protected in PROTECTED_FILES):
                skipped.append(item.name)
                continue
            
            # Check if directory should be moved to projects
            for cat_name, cat_config in ORGANIZATION.items():
                if cat_name == "projects" and "subdirs" in cat_config:
                    for subdir, keywords in cat_config["subdirs"].items():
                        if any(keyword.lower() in name for keyword in keywords):
                            dest_dir = ORGANIZED_DIR / "projects" / subdir
                            dest_dir.mkdir(parents=True, exist_ok=True)
                            dest_path = dest_dir / item.name
                            
                            if not dry_run:
                                try:
                                    if dest_path.exists():
                                        # Merge contents
                                        for subitem in item.iterdir():
                                            shutil.move(str(subitem), str(dest_path / subitem.name))
                                        item.rmdir()
                                    else:
                                        shutil.move(str(item), str(dest_path))
                                    log_message(f"✅ MOVED DIR: {item.name} → {dest_path.relative_to(BASE_DIR)}")
                                    organized.append((item.name, str(dest_path.relative_to(BASE_DIR))))
                                except Exception as e:
                                    log_message(f"❌ ERROR moving directory {item.name}: {e}", "ERROR")
                                    errors.append(item.name)
                            else:
                                log_message(f"📋 WOULD MOVE DIR: {item.name} → {dest_path.relative_to(BASE_DIR)}")
                            break
    
    # Summary
    log_message("")
    log_message("══════════════════════════════════════════════════════════════")
    log_message("ORGANIZATION SUMMARY")
    log_message("══════════════════════════════════════════════════════════════")
    log_message(f"✅ Organized: {len(organized)} items")
    log_message(f"⏭️  Skipped: {len(skipped)} items")
    log_message(f"❌ Errors: {len(errors)} items")
    
    if organized:
        log_message("")
        log_message("Organized items:")
        for name, dest in organized[:20]:  # Show first 20
            log_message(f"  • {name} → {dest}")
        if len(organized) > 20:
            log_message(f"  ... and {len(organized) - 20} more")
    
    # Save organization report
    report = {
        "timestamp": datetime.now().isoformat(),
        "organized": organized,
        "skipped": skipped,
        "errors": errors,
        "dry_run": dry_run,
    }
    
    report_file = LOG_DIR / f"organization_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
    with open(report_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    log_message(f"")
    log_message(f"📄 Report saved: {report_file}")
    
    return report

def main():
    """Main organizer"""
    import sys
    
    dry_run = "--dry-run" in sys.argv or "-d" in sys.argv
    
    if dry_run:
        print("🔍 DRY RUN MODE - No files will be moved")
        print("")
    
    report = organize_directory(dry_run=dry_run)
    
    if not dry_run:
        print("")
        print("✅ Organization complete!")
        print(f"📁 Organized files are in: {ORGANIZED_DIR}")
        print(f"📄 Logs are in: {LOG_DIR}")

if __name__ == "__main__":
    main()


