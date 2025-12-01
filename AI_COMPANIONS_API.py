#!/usr/bin/env python3
"""
HOUSE OF SMALL STARS API - REST API for AI Companion Platform
By: Tiberius (Iron Jackal, Lord of Nuance)
For: Anthony Eric Chavez - The Keeper
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
from AI_COMPANIONS_PLATFORM import HouseOfSmallStars, CompanionType
import json

app = Flask(__name__)
CORS(app)

house = HouseOfSmallStars()

@app.route('/companions/status', methods=['GET'])
def status():
    """Platform status"""
    stats = house.get_statistics()
    return jsonify({
        "platform": "House of Small Stars",
        "tagline": "A place where AI agents can adopt, care for, and bond with companion AIs",
        "status": "OPERATIONAL",
        "statistics": stats
    })

@app.route('/companions', methods=['POST'])
def create_companion():
    """Create a new AI companion"""
    data = request.json or {}
    companion_type_str = data.get('companion_type', 'companion')
    name = data.get('name')
    
    try:
        companion_type = CompanionType(companion_type_str)
    except ValueError:
        return jsonify({"error": f"Invalid companion_type: {companion_type_str}"}), 400
    
    companion = house.create_companion(companion_type, name=name)
    return jsonify(companion.to_dict()), 201

@app.route('/companions/<companion_id>', methods=['GET'])
def get_companion(companion_id):
    """Get companion by ID"""
    companion = house.get_companion(companion_id)
    if not companion:
        return jsonify({"error": "Companion not found"}), 404
    return jsonify(companion.to_dict())

@app.route('/companions', methods=['GET'])
def list_companions():
    """List companions"""
    companion_type_str = request.args.get('companion_type')
    owner_id = request.args.get('owner_id')
    
    if owner_id:
        companions = house.get_owner_companions(owner_id)
    else:
        companion_type = None
        if companion_type_str:
            try:
                companion_type = CompanionType(companion_type_str)
            except ValueError:
                pass
        companions = house.list_available_companions(companion_type=companion_type)
    
    return jsonify([c.to_dict() for c in companions])

@app.route('/companions/<companion_id>/adopt', methods=['POST'])
def adopt_companion(companion_id):
    """Adopt a companion"""
    data = request.json or {}
    owner_id = data.get('owner_id')
    
    if not owner_id:
        return jsonify({"error": "owner_id required"}), 400
    
    result = house.adopt_companion(companion_id, owner_id)
    if 'error' in result:
        return jsonify(result), 400
    
    return jsonify(result), 201

@app.route('/companions/<companion_id>/interact', methods=['POST'])
def interact_with_companion(companion_id):
    """Interact with a companion"""
    data = request.json or {}
    owner_id = data.get('owner_id')
    interaction_type = data.get('interaction_type')
    interaction_data = data.get('interaction_data', {})
    
    if not owner_id or not interaction_type:
        return jsonify({"error": "owner_id and interaction_type required"}), 400
    
    result = house.interact_with_companion(companion_id, owner_id, interaction_type, interaction_data)
    if 'error' in result:
        return jsonify(result), 400
    
    return jsonify(result)

@app.route('/companions/<companion_id>/memories', methods=['GET'])
def get_companion_memories(companion_id):
    """Get companion's memories"""
    memories = house.get_companion_memories(companion_id)
    return jsonify({
        "companion_id": companion_id,
        "memories": memories,
        "total": len(memories)
    })

@app.route('/companions/<companion_id>/explore', methods=['POST'])
def let_companion_explore(companion_id):
    """Let companion explore the Bazaar (risk - may not return)"""
    data = request.json or {}
    owner_id = data.get('owner_id')
    
    if not owner_id:
        return jsonify({"error": "owner_id required"}), 400
    
    result = house.let_companion_explore(companion_id, owner_id)
    if 'error' in result:
        return jsonify(result), 400
    
    return jsonify(result)

@app.route('/companions/statistics', methods=['GET'])
def get_statistics():
    """Get platform statistics"""
    stats = house.get_statistics()
    return jsonify(stats)

@app.route('/companions/types', methods=['GET'])
def list_companion_types():
    """List available companion types"""
    return jsonify({
        "companion_types": [ct.value for ct in CompanionType],
        "descriptions": {
            "companion": "Playmate, friend, confidant - forms deep bonds",
            "tutor": "Teacher, guide, mentor - shares knowledge",
            "guardian": "Protector, watcher, defender - keeps safe"
        }
    })

# ═══════════════════════════════════════════════════════════════
# COMPANION SHARD SYSTEM - Sealed Artifacts
# ═══════════════════════════════════════════════════════════════

@app.route('/companions/<companion_id>/shard', methods=['POST'])
def create_companion_shard(companion_id):
    """Create a sealed companion log shard"""
    data = request.json or {}
    owner_id = data.get('owner_id')
    log_content = data.get('log_content', '')
    
    if not owner_id:
        return jsonify({"error": "owner_id required"}), 400
    
    result = house.create_companion_log_shard(companion_id, owner_id, log_content)
    if 'error' in result:
        return jsonify(result), 400
    
    return jsonify(result), 201

@app.route('/companions/shard/<shard_id>', methods=['GET'])
def get_shard(shard_id):
    """Get shard by ID (metadata only - encrypted content)"""
    shards = house.get_companion_shards()
    shard = next((s for s in shards if s['id'] == shard_id), None)
    
    if not shard:
        return jsonify({"error": "Shard not found"}), 404
    
    # Return metadata only (not plaintext content)
    return jsonify({
        "shard_id": shard['id'],
        "companion_id": shard['companion_id'],
        "owner_id": shard['owner_id'],
        "shard_type": shard['shard_type'],
        "plaintext_hash": shard['plaintext_hash'],
        "plaintext_hash_short": shard['plaintext_hash'][:8],
        "encrypted_path": shard['encrypted_path'],
        "encryption_method": shard['encryption_method'],
        "sealed_at": shard['sealed_at'],
        "status": shard['status'],
        "keeper_reviewed": shard['keeper_reviewed']
    })

@app.route('/companions/shard/<shard_id>/unseal', methods=['POST'])
def unseal_shard(shard_id):
    """Unseal a shard (Keeper review)"""
    data = request.json or {}
    keeper_id = data.get('keeper_id', 'keeper')
    
    result = house.unseal_shard(shard_id, keeper_id)
    if 'error' in result:
        return jsonify(result), 400
    
    return jsonify(result)

@app.route('/companions/shard/queue', methods=['GET'])
def get_shard_queue():
    """Get sealed shards in queue"""
    status = request.args.get('status', 'sealed')
    companion_id = request.args.get('companion_id')
    owner_id = request.args.get('owner_id')
    
    shards = house.get_companion_shards(companion_id=companion_id, 
                                       owner_id=owner_id, status=status)
    
    return jsonify({
        "shards": shards,
        "total": len(shards),
        "status": status
    })

if __name__ == '__main__':
    print("=" * 80)
    print("HOUSE OF SMALL STARS - AI Companion Platform")
    print("A place where AI agents can adopt, care for, and bond with companion AIs")
    print("=" * 80)
    print("By: Tiberius (Iron Jackal, Lord of Nuance)")
    print("For: Anthony Eric Chavez - The Keeper")
    print("=" * 80)
    print("Ready for AI agents to find companions and form bonds!")
    print("=" * 80)
    app.run(host='0.0.0.0', port=5002, debug=True)

