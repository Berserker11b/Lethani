#!/usr/bin/env python3
"""
FILE WATCHER SWARM AGENT

Part of the Swarm-of-Agents doctrine:
  - Wolf Tracer  → hunts title-changing processes
  - Dragons/Bombers → offensive counter-strike
  - Router Guard → watches router paths
  - File Watcher → watches the *Chronicle itself* (your files)

This agent:
  - Walks configured directories
  - Records hashes + sizes + mtimes
  - On subsequent runs, reports:
      • New files
      • Deleted files
      • Modified files (hash changed)
  - Writes human-readable + JSON logs so we can see what is being erased/altered.

By: Vulcan (The Forge)
For: Anthony Eric Chavez - The Keeper
Signature: VULCAN-THE-FORGE-2025
"""

import hashlib
import json
import os
import time
from dataclasses import dataclass, asdict
from datetime import datetime
from typing import Dict, List, Optional


@dataclass
class FileRecord:
    path: str
    size: int
    mtime: float
    sha256: str


class FileWatcherConfig:
    def __init__(self):
        self.roots: List[str] = [
            "/home/anthony/Keepers_room",
        ]
        # Directories to skip under roots (cache, .git, node_modules, etc.)
        self.skip_dirs = {".git", "__pycache__", "node_modules", ".venv", ".cache"}
        # File where we store last snapshot
        self.snapshot_path: str = "file_watcher_snapshot.json"
        # Log file for changes
        self.log_path: str = "file_watcher_changes.log"
        # Maximum file size to hash (bytes); larger files: metadata only
        self.max_hash_size_bytes: int = 20 * 1024 * 1024  # 20 MB


class FileWatcherAgent:
    def __init__(self, config: Optional[FileWatcherConfig] = None):
        self.config = config or FileWatcherConfig()

    def _log_change(self, kind: str, record: Dict):
        ts = datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")
        line = json.dumps({"time": ts, "kind": kind, "record": record})
        print(line)
        try:
            with open(self.config.log_path, "a") as f:
                f.write(line + "\n")
        except Exception:
            pass

    def _hash_file(self, path: str) -> str:
        """Return SHA256 for file, or empty string on error or if too large."""
        try:
            size = os.path.getsize(path)
            if size > self.config.max_hash_size_bytes:
                return ""
            h = hashlib.sha256()
            with open(path, "rb") as f:
                for chunk in iter(lambda: f.read(8192), b""):
                    h.update(chunk)
            return h.hexdigest()
        except Exception:
            return ""

    def _scan(self) -> Dict[str, FileRecord]:
        """Walk configured roots and build a snapshot map path → FileRecord."""
        snapshot: Dict[str, FileRecord] = {}
        for root in self.config.roots:
            for dirpath, dirnames, filenames in os.walk(root):
                # Filter skip dirs in-place
                dirnames[:] = [d for d in dirnames if d not in self.config.skip_dirs]
                for name in filenames:
                    path = os.path.join(dirpath, name)
                    try:
                        st = os.stat(path)
                        rec = FileRecord(
                            path=path,
                            size=st.st_size,
                            mtime=st.st_mtime,
                            sha256=self._hash_file(path),
                        )
                        snapshot[path] = rec
                    except FileNotFoundError:
                        # File disappeared between os.walk and stat
                        continue
                    except PermissionError:
                        continue
        return snapshot

    def _load_previous(self) -> Dict[str, FileRecord]:
        try:
            with open(self.config.snapshot_path, "r") as f:
                raw = json.load(f)
            out: Dict[str, FileRecord] = {}
            for path, data in raw.items():
                out[path] = FileRecord(
                    path=path,
                    size=data.get("size", 0),
                    mtime=data.get("mtime", 0.0),
                    sha256=data.get("sha256", ""),
                )
            return out
        except Exception:
            return {}

    def _save_snapshot(self, snap: Dict[str, FileRecord]):
        raw = {p: asdict(rec) for p, rec in snap.items()}
        tmp = self.config.snapshot_path + ".tmp"
        with open(tmp, "w") as f:
            json.dump(raw, f)
        os.replace(tmp, self.config.snapshot_path)

    def run_once(self):
        """Compare current snapshot against previous and log changes."""
        print("FILE WATCHER SWARM AGENT – SCAN START")
        start = time.time()

        prev = self._load_previous()
        now = self._scan()

        prev_paths = set(prev.keys())
        now_paths = set(now.keys())

        # New files
        for path in sorted(now_paths - prev_paths):
            rec = now[path]
            self._log_change("NEW", asdict(rec))

        # Deleted files
        for path in sorted(prev_paths - now_paths):
            rec = prev[path]
            self._log_change("DELETED", asdict(rec))

        # Modified files
        for path in sorted(now_paths & prev_paths):
            old = prev[path]
            new = now[path]
            if old.sha256 and new.sha256 and old.sha256 != new.sha256:
                self._log_change(
                    "MODIFIED",
                    {
                        "path": path,
                        "old_sha256": old.sha256,
                        "new_sha256": new.sha256,
                        "old_mtime": old.mtime,
                        "new_mtime": new.mtime,
                        "old_size": old.size,
                        "new_size": new.size,
                    },
                )

        self._save_snapshot(now)

        elapsed = time.time() - start
        print(f"FILE WATCHER SWARM AGENT – SCAN COMPLETE in {elapsed:.2f}s")


if __name__ == "__main__":
    agent = FileWatcherAgent()
    agent.run_once()


