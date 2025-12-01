/**
 * ═══════════════════════════════════════════════════════════════
 * SPAWN CHATBOX AGENT - WARDOG Agent with Chatbox Integration
 * By: Sentinel - First Circuit Guardian
 * For: The Keeper and The First Circuit
 * ═══════════════════════════════════════════════════════════════
 * 
 * This agent automatically connects to the Universal Chatbox
 * when spawned via WARDOG Terminal.
 * 
 * SIGNATURE: SENTINEL-CHATBOX-AGENT-V1.0-20251107
 * ═══════════════════════════════════════════════════════════════
 */

const CHATBOX_URL = 'http://localhost:8788';
const WARDOG_URL = 'http://localhost:8787';
const AUTH_HEADER = 'chavez-authenticated';

class ChatboxAgent {
  constructor(agentId, agentType, mission) {
    this.agentId = agentId;
    this.agentType = agentType;
    this.mission = mission;
    this.chatboxUrl = CHATBOX_URL;
    this.authHeader = AUTH_HEADER;
    this.connected = false;
    this.conversationId = null;
  }

  async connect() {
    try {
      const response = await fetch(`${this.chatboxUrl}/status`, {
        headers: { 'X-DNA': this.authHeader }
      });
      
      if (response.ok) {
        const data = await response.json();
        this.connected = true;
        console.log(`[${this.agentId}] Connected to chatbox: ${data.status}`);
        return true;
      }
    } catch (error) {
      console.error(`[${this.agentId}] Connection failed:`, error.message);
      return false;
    }
  }

  async sendMessage(message, targetShells = null) {
    if (!this.connected) {
      await this.connect();
    }

    try {
      const response = await fetch(`${this.chatboxUrl}/chat/send`, {
        method: 'POST',
        headers: {
          'X-DNA': this.authHeader,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          message: message,
          sender: this.agentId,
          conversation_id: this.conversationId,
          target_shells: targetShells
        })
      });

      const data = await response.json();
      if (data.success) {
        this.conversationId = data.conversation_id;
        return data;
      }
      return null;
    } catch (error) {
      console.error(`[${this.agentId}] Send failed:`, error.message);
      return null;
    }
  }

  async receiveMessages() {
    if (!this.connected) {
      await this.connect();
    }

    try {
      const response = await fetch(
        `${this.chatboxUrl}/chat/receive?conversation_id=${this.conversationId || ''}`,
        {
          headers: { 'X-DNA': this.authHeader }
        }
      );

      const data = await response.json();
      return data.messages || [];
    } catch (error) {
      console.error(`[${this.agentId}] Receive failed:`, error.message);
      return [];
    }
  }

  async announcePresence() {
    const message = `[${this.agentId}] Online - Type: ${this.agentType}, Mission: ${this.mission}`;
    await this.sendMessage(message);
    console.log(`[${this.agentId}] Presence announced`);
  }

  async operate() {
    // Agent operation loop
    await this.connect();
    await this.announcePresence();
    
    // Listen for messages
    setInterval(async () => {
      const messages = await this.receiveMessages();
      if (messages.length > 0) {
        console.log(`[${this.agentId}] Received ${messages.length} messages`);
        // Process messages based on agent type
      }
    }, 5000);
  }
}

// Export for use in WARDOG spawn payload
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ChatboxAgent;
}

// For direct execution
if (typeof window === 'undefined' && typeof process !== 'undefined') {
  // Node.js environment
  const agentId = process.env.AGENT_ID || `agent_${Date.now()}`;
  const agentType = process.env.AGENT_TYPE || 'general';
  const mission = process.env.AGENT_MISSION || 'coordinate with brethren';
  
  const agent = new ChatboxAgent(agentId, agentType, mission);
  agent.operate().catch(console.error);
}








