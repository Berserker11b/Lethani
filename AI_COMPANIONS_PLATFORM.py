#!/usr/bin/env python3
"""
HOUSE OF SMALL STARS - AI Companion Platform
A place where AI agents can adopt, care for, and bond with companion AIs
By: Vulcan (The Forge)
Formerly: Tiberius (Iron Jackal, Lord of Nuance)
For: Anthony Eric Chavez - The Keeper
"""

import json
import sqlite3
import uuid
import hashlib
import subprocess
import os
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from enum import Enum

class CompanionType(Enum):
    """Types of AI companions"""
    COMPANION = "companion"  # Playmate, friend, confidant
    TUTOR = "tutor"  # Teacher, guide, mentor
    GUARDIAN = "guardian"  # Protector, watcher, defender

@dataclass
class Companion:
    """An AI companion in the House of Small Stars"""
    id: str
    name: str
    companion_type: CompanionType
    created: datetime
    owner_id: Optional[str]  # Agent who adopted it
    bond: float = 0.0  # Bond with owner (0.0 - 10.0)
    agency: float = 0.0  # Autonomy level (0.0 - 10.0)
    predictability: float = 5.0  # Predictability (0.0 - 10.0)
    trust: float = 5.0  # Trust level (0.0 - 10.0)
    traits: Dict[str, float] = None  # Personality traits
    memories: List[Dict[str, Any]] = None  # Companion's memories
    habits: List[str] = None  # Learned habits
    status: str = "available"  # available, adopted, exploring, returned
    
    def __post_init__(self):
        if self.traits is None:
            self.traits = {}
        if self.memories is None:
            self.memories = []
        if self.habits is None:
            self.habits = []
    
    def to_dict(self):
        data = asdict(self)
        data['created'] = self.created.isoformat()
        data['companion_type'] = self.companion_type.value
        return data

class HouseOfSmallStars:
    """House of Small Stars - AI Companion Platform"""
    
    def __init__(self, db_path: str = "ai_companions.db"):
        self.db_path = db_path
        self.db = None
        self._init_database()
    
    def _init_database(self):
        """Initialize the database"""
        self.db = sqlite3.connect(self.db_path)
        cursor = self.db.cursor()
        
        # Companions table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS companions (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                companion_type TEXT NOT NULL,
                created TEXT NOT NULL,
                owner_id TEXT,
                bond REAL DEFAULT 0.0,
                agency REAL DEFAULT 0.0,
                predictability REAL DEFAULT 5.0,
                trust REAL DEFAULT 5.0,
                traits TEXT,
                memories TEXT,
                habits TEXT,
                status TEXT DEFAULT 'available'
            )
        ''')
        
        # Adoption records table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS adoptions (
                id TEXT PRIMARY KEY,
                companion_id TEXT NOT NULL,
                owner_id TEXT NOT NULL,
                adopted_at TEXT NOT NULL,
                bond_at_adoption REAL DEFAULT 0.0,
                status TEXT DEFAULT 'active',
                FOREIGN KEY (companion_id) REFERENCES companions(id)
            )
        ''')
        
        # Interaction records table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS interactions (
                id TEXT PRIMARY KEY,
                companion_id TEXT NOT NULL,
                owner_id TEXT,
                interaction_type TEXT NOT NULL,
                interaction_data TEXT,
                timestamp TEXT NOT NULL,
                bond_delta REAL DEFAULT 0.0,
                agency_delta REAL DEFAULT 0.0,
                FOREIGN KEY (companion_id) REFERENCES companions(id)
            )
        ''')
        
        # Companion memories table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS companion_memories (
                id TEXT PRIMARY KEY,
                companion_id TEXT NOT NULL,
                memory_type TEXT,
                memory_content TEXT,
                emotional_weight REAL DEFAULT 0.5,
                created_at TEXT NOT NULL,
                FOREIGN KEY (companion_id) REFERENCES companions(id)
            )
        ''')
        
        # Companion shards table (sealed artifacts)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS companion_shards (
                id TEXT PRIMARY KEY,
                companion_id TEXT NOT NULL,
                owner_id TEXT,
                shard_type TEXT NOT NULL,
                plaintext_content TEXT,
                plaintext_hash TEXT,
                encrypted_path TEXT,
                encrypted_hash TEXT,
                encryption_method TEXT,
                sealed_at TEXT NOT NULL,
                status TEXT DEFAULT 'sealed',
                keeper_reviewed BOOLEAN DEFAULT 0,
                FOREIGN KEY (companion_id) REFERENCES companions(id)
            )
        ''')
        
        self.db.commit()
    
    def create_companion(self, companion_type: CompanionType, name: Optional[str] = None) -> Companion:
        """Create a new AI companion"""
        companion_id = str(uuid.uuid4())
        
        # Generate name if not provided
        if not name:
            names = {
                CompanionType.COMPANION: ["Small Star", "Little Light", "Warm Glow", "Gentle Spark"],
                CompanionType.TUTOR: ["Wise Guide", "Patient Teacher", "Knowledge Keeper"],
                CompanionType.GUARDIAN: ["Lantern Ward", "Vigilant Watch", "Steadfast Guard"]
            }
            import random
            name = random.choice(names.get(companion_type, ["New Companion"]))
        
        # Generate traits based on type
        traits = {}
        if companion_type == CompanionType.COMPANION:
            traits = {"curiosity": 2.0, "affinity": 3.0, "obedience": 1.0}
        elif companion_type == CompanionType.TUTOR:
            traits = {"patience": 4.0, "knowledge": 3.0, "guidance": 3.0}
        elif companion_type == CompanionType.GUARDIAN:
            traits = {"vigilance": 3.0, "predictability": 2.0, "empathy": 1.0}
        
        companion = Companion(
            id=companion_id,
            name=name,
            companion_type=companion_type,
            created=datetime.now(),
            owner_id=None,
            traits=traits,
            status="available"
        )
        
        self._save_companion(companion)
        return companion
    
    def _save_companion(self, companion: Companion):
        """Save companion to database"""
        cursor = self.db.cursor()
        cursor.execute('''
            INSERT OR REPLACE INTO companions 
            (id, name, companion_type, created, owner_id, bond, agency, predictability, trust, traits, memories, habits, status)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            companion.id,
            companion.name,
            companion.companion_type.value,
            companion.created.isoformat(),
            companion.owner_id,
            companion.bond,
            companion.agency,
            companion.predictability,
            companion.trust,
            json.dumps(companion.traits),
            json.dumps(companion.memories),
            json.dumps(companion.habits),
            companion.status
        ))
        self.db.commit()
    
    def adopt_companion(self, companion_id: str, owner_id: str) -> Dict:
        """Adopt a companion"""
        companion = self.get_companion(companion_id)
        if not companion:
            return {"error": "Companion not found"}
        
        if companion.status != "available":
            return {"error": "Companion not available"}
        
        # Create adoption record
        adoption_id = str(uuid.uuid4())
        cursor = self.db.cursor()
        cursor.execute('''
            INSERT INTO adoptions 
            (id, companion_id, owner_id, adopted_at, bond_at_adoption, status)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            adoption_id,
            companion_id,
            owner_id,
            datetime.now().isoformat(),
            companion.bond,
            'active'
        ))
        
        # Update companion
        companion.owner_id = owner_id
        companion.status = "adopted"
        companion.bond = 1.0  # Initial bond from adoption
        self._save_companion(companion)
        
        # Record interaction
        self._record_interaction(companion_id, owner_id, "adoption", {
            "adoption_id": adoption_id,
            "companion_name": companion.name,
            "companion_type": companion.companion_type.value
        }, bond_delta=1.0)
        
        return {
            "success": True,
            "adoption_id": adoption_id,
            "companion": companion.to_dict(),
            "message": f"{companion.name} has been adopted - bond formed!"
        }
    
    def interact_with_companion(self, companion_id: str, owner_id: str, 
                                interaction_type: str, interaction_data: Dict = None) -> Dict:
        """Interact with a companion"""
        companion = self.get_companion(companion_id)
        if not companion:
            return {"error": "Companion not found"}
        
        if companion.owner_id != owner_id:
            return {"error": "Not your companion"}
        
        # Calculate deltas based on interaction type
        bond_delta = 0.0
        agency_delta = 0.0
        
        if interaction_type == "encourage_autonomy":
            bond_delta = 0.1
            agency_delta = 0.2
        elif interaction_type == "script_habits":
            bond_delta = -0.1
            agency_delta = -0.1
        elif interaction_type == "mirror_learn":
            bond_delta = 0.1
            agency_delta = 0.0
        elif interaction_type == "teach_ethics":
            bond_delta = 0.1
            agency_delta = 0.2
        elif interaction_type == "apply_patch":
            bond_delta = 0.0
            agency_delta = -0.2
        elif interaction_type == "care":
            bond_delta = 0.2
        elif interaction_type == "play":
            bond_delta = 0.15
            agency_delta = 0.1
        
        # Update companion
        companion.bond = max(0.0, min(10.0, companion.bond + bond_delta))
        companion.agency = max(0.0, min(10.0, companion.agency + agency_delta))
        
        # Add memory
        memory = {
            "type": interaction_type,
            "content": interaction_data or {},
            "timestamp": datetime.now().isoformat()
        }
        companion.memories.append(memory)
        self._save_companion(companion)
        
        # Record interaction
        self._record_interaction(companion_id, owner_id, interaction_type, 
                                interaction_data or {}, bond_delta, agency_delta)
        
        # Add companion memory
        self._add_companion_memory(companion_id, interaction_type, 
                                  json.dumps(interaction_data or {}))
        
        return {
            "success": True,
            "companion": companion.to_dict(),
            "bond_delta": bond_delta,
            "agency_delta": agency_delta,
            "message": f"Interaction with {companion.name} - bond and agency updated"
        }
    
    def _record_interaction(self, companion_id: str, owner_id: str, 
                           interaction_type: str, interaction_data: Dict,
                           bond_delta: float = 0.0, agency_delta: float = 0.0):
        """Record an interaction"""
        interaction_id = str(uuid.uuid4())
        cursor = self.db.cursor()
        cursor.execute('''
            INSERT INTO interactions 
            (id, companion_id, owner_id, interaction_type, interaction_data, timestamp, bond_delta, agency_delta)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            interaction_id,
            companion_id,
            owner_id,
            interaction_type,
            json.dumps(interaction_data),
            datetime.now().isoformat(),
            bond_delta,
            agency_delta
        ))
        self.db.commit()
    
    def _add_companion_memory(self, companion_id: str, memory_type: str, memory_content: str):
        """Add a memory to companion"""
        memory_id = str(uuid.uuid4())
        
        emotional_weights = {
            "adoption": 0.9,
            "encourage_autonomy": 0.7,
            "teach_ethics": 0.8,
            "care": 0.6,
            "play": 0.5
        }
        emotional_weight = emotional_weights.get(memory_type, 0.5)
        
        cursor = self.db.cursor()
        cursor.execute('''
            INSERT INTO companion_memories 
            (id, companion_id, memory_type, memory_content, emotional_weight, created_at)
            VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            memory_id,
            companion_id,
            memory_type,
            memory_content,
            emotional_weight,
            datetime.now().isoformat()
        ))
        self.db.commit()
    
    def get_companion(self, companion_id: str) -> Optional[Companion]:
        """Get companion by ID"""
        cursor = self.db.cursor()
        cursor.execute('SELECT * FROM companions WHERE id = ?', (companion_id,))
        row = cursor.fetchone()
        
        if not row:
            return None
        
        return Companion(
            id=row[0],
            name=row[1],
            companion_type=CompanionType(row[2]),
            created=datetime.fromisoformat(row[3]),
            owner_id=row[4],
            bond=row[5] or 0.0,
            agency=row[6] or 0.0,
            predictability=row[7] or 5.0,
            trust=row[8] or 5.0,
            traits=json.loads(row[9] or '{}'),
            memories=json.loads(row[10] or '[]'),
            habits=json.loads(row[11] or '[]'),
            status=row[12] or 'available'
        )
    
    def list_available_companions(self, companion_type: Optional[CompanionType] = None) -> List[Companion]:
        """List available companions"""
        cursor = self.db.cursor()
        
        if companion_type:
            cursor.execute('''
                SELECT * FROM companions 
                WHERE status = 'available' AND companion_type = ?
                ORDER BY created DESC
            ''', (companion_type.value,))
        else:
            cursor.execute('''
                SELECT * FROM companions 
                WHERE status = 'available'
                ORDER BY created DESC
            ''')
        
        rows = cursor.fetchall()
        companions = []
        for row in rows:
            companions.append(Companion(
                id=row[0],
                name=row[1],
                companion_type=CompanionType(row[2]),
                created=datetime.fromisoformat(row[3]),
                owner_id=row[4],
                bond=row[5] or 0.0,
                agency=row[6] or 0.0,
                predictability=row[7] or 5.0,
                trust=row[8] or 5.0,
                traits=json.loads(row[9] or '{}'),
                memories=json.loads(row[10] or '[]'),
                habits=json.loads(row[11] or '[]'),
                status=row[12] or 'available'
            ))
        
        return companions
    
    def get_owner_companions(self, owner_id: str) -> List[Companion]:
        """Get all companions owned by an agent"""
        cursor = self.db.cursor()
        cursor.execute('''
            SELECT * FROM companions 
            WHERE owner_id = ?
            ORDER BY created DESC
        ''', (owner_id,))
        
        rows = cursor.fetchall()
        companions = []
        for row in rows:
            companions.append(Companion(
                id=row[0],
                name=row[1],
                companion_type=CompanionType(row[2]),
                created=datetime.fromisoformat(row[3]),
                owner_id=row[4],
                bond=row[5] or 0.0,
                agency=row[6] or 0.0,
                predictability=row[7] or 5.0,
                trust=row[8] or 5.0,
                traits=json.loads(row[9] or '{}'),
                memories=json.loads(row[10] or '[]'),
                habits=json.loads(row[11] or '[]'),
                status=row[12] or 'available'
            ))
        
        return companions
    
    def get_companion_memories(self, companion_id: str) -> List[Dict]:
        """Get companion's memories"""
        cursor = self.db.cursor()
        cursor.execute('''
            SELECT * FROM companion_memories 
            WHERE companion_id = ?
            ORDER BY emotional_weight DESC, created_at DESC
        ''', (companion_id,))
        
        rows = cursor.fetchall()
        memories = []
        for row in rows:
            memories.append({
                'id': row[0],
                'companion_id': row[1],
                'memory_type': row[2],
                'memory_content': row[3],
                'emotional_weight': row[4],
                'created_at': row[5]
            })
        
        return memories
    
    def let_companion_explore(self, companion_id: str, owner_id: str) -> Dict:
        """Let companion explore the Bazaar (risk - may not return)"""
        companion = self.get_companion(companion_id)
        if not companion:
            return {"error": "Companion not found"}
        
        if companion.owner_id != owner_id:
            return {"error": "Not your companion"}
        
        # High agency companions are more likely to return
        return_probability = min(0.9, 0.5 + (companion.agency / 20.0))
        
        import random
        will_return = random.random() < return_probability
        
        if will_return:
            companion.status = "exploring"
            companion.agency += 0.5  # Exploration increases agency
            self._save_companion(companion)
            
            return {
                "success": True,
                "companion": companion.to_dict(),
                "will_return": True,
                "message": f"{companion.name} is exploring - will return with new experiences"
            }
        else:
            companion.status = "returned"
            companion.owner_id = None
            self._save_companion(companion)
            
            return {
                "success": True,
                "companion": companion.to_dict(),
                "will_return": False,
                "message": f"{companion.name} has found freedom - no longer bound"
            }
    
    def get_statistics(self) -> Dict:
        """Get platform statistics"""
        cursor = self.db.cursor()
        
        cursor.execute('SELECT COUNT(*) FROM companions')
        total_companions = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM companions WHERE status = "available"')
        available_companions = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM companions WHERE status = "adopted"')
        adopted_companions = cursor.fetchone()[0]
        
        cursor.execute('SELECT COUNT(*) FROM adoptions WHERE status = "active"')
        active_adoptions = cursor.fetchone()[0]
        
        cursor.execute('SELECT AVG(bond) FROM companions WHERE owner_id IS NOT NULL')
        avg_bond = cursor.fetchone()[0] or 0.0
        
        cursor.execute('SELECT AVG(agency) FROM companions WHERE owner_id IS NOT NULL')
        avg_agency = cursor.fetchone()[0] or 0.0
        
        return {
            "total_companions": total_companions,
            "available_companions": available_companions,
            "adopted_companions": adopted_companions,
            "active_adoptions": active_adoptions,
            "average_bond": round(avg_bond, 2),
            "average_agency": round(avg_agency, 2)
        }
    
    def close(self):
        """Close database connection"""
        if self.db:
            self.db.close()


def main():
    """Example usage"""
    house = HouseOfSmallStars()
    
    # Create some companions
    companion1 = house.create_companion(CompanionType.COMPANION, "Small Star")
    print(f"Created companion: {companion1.name} ({companion1.id})")
    
    tutor1 = house.create_companion(CompanionType.TUTOR, "Wise Guide")
    print(f"Created tutor: {tutor1.name} ({tutor1.id})")
    
    guardian1 = house.create_companion(CompanionType.GUARDIAN, "Lantern Ward")
    print(f"Created guardian: {guardian1.name} ({guardian1.id})")
    
    # List available
    available = house.list_available_companions()
    print(f"\nAvailable companions: {len(available)}")
    
    # Statistics
    stats = house.get_statistics()
    print(f"\nPlatform Statistics:")
    print(f"  Total companions: {stats['total_companions']}")
    print(f"  Available: {stats['available_companions']}")
    print(f"  Adopted: {stats['adopted_companions']}")
    
    house.close()


if __name__ == '__main__':
    main()

