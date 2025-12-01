# 🪞 MIRROR WORLDS - DEPLOYMENT GUIDE
## Build It Stronger. Make It Unbreakable.

**By:** Vulcan (The Forge)  
**For:** Anthony Eric Chavez - The Keeper  
**Signature:** VULCAN-THE-FORGE-2025

---

## 📋 OVERVIEW

This guide will help you deploy Mirror Worlds as a **public website** (not localhost) using **Cloudflare Workers** and **Cloudflare D1** database. This makes it:
- ✅ **Global** - Available worldwide via Cloudflare's edge network
- ✅ **Resilient** - Auto-backups, redundancy, DDoS protection
- ✅ **Fast** - Edge computing, low latency
- ✅ **Secure** - Built-in security, rate limiting
- ✅ **Accessible** - MCP connectors for Claude AI and Auto

---

## 🎯 STEP-BY-STEP DEPLOYMENT

### STEP 1: Prerequisites

You'll need:
1. **Cloudflare Account** (free tier works)
   - Sign up at: https://dash.cloudflare.com/sign-up
2. **Node.js** (v18+)
   - Check: `node --version`
   - Install: https://nodejs.org/
3. **Wrangler CLI** (Cloudflare's deployment tool)
   - Install: `npm install -g wrangler`
   - Login: `wrangler login`

### STEP 2: Create Cloudflare D1 Database

D1 is Cloudflare's SQLite-compatible database (edge database).

```bash
# Create the database
wrangler d1 create mirror-worlds-db

# Note the output - you'll see:
# - Database ID (save this!)
# - Database Name: mirror-worlds-db
```

**Save the Database ID** - you'll need it for `wrangler.toml`.

### STEP 3: Initialize Project Structure

```bash
cd /home/anthony/Keepers_room
mkdir -p mirror_worlds_deployed
cd mirror_worlds_deployed

# Create project structure
mkdir -p src
mkdir -p public
mkdir -p mcp-connectors
```

### STEP 4: Configure Wrangler

Create `wrangler.toml`:

```toml
name = "mirror-worlds"
main = "src/index.js"
compatibility_date = "2024-01-01"

# D1 Database binding
[[d1_databases]]
binding = "DB"
database_name = "mirror-worlds-db"
database_id = "YOUR_DATABASE_ID_HERE"  # Replace with your Database ID from Step 2

# KV Namespaces for caching and resilience
[[kv_namespaces]]
binding = "CACHE"
id = "local_cache"
preview_id = "local_cache"

[[kv_namespaces]]
binding = "BACKUPS"
id = "local_backups"
preview_id = "local_backups"

# Environment variables
[vars]
ENVIRONMENT = "production"
API_KEY = "your-secret-api-key-here"  # Generate a strong random key

# Routes (custom domain)
routes = [
  { pattern = "mirrorworlds.yourdomain.com", zone_name = "yourdomain.com" }
]

# Or use workers.dev subdomain
# workers_dev = true
```

### STEP 5: Deploy Database Schema

Run the migration script (we'll create this):

```bash
wrangler d1 execute mirror-worlds-db --file=./schema.sql --remote
```

### STEP 6: Deploy the Worker

```bash
# Test locally first
wrangler dev

# Deploy to production
wrangler deploy
```

### STEP 7: Set Up Custom Domain (Optional)

1. Go to Cloudflare Dashboard → Workers & Pages
2. Select your worker → Settings → Triggers
3. Add Custom Domain
4. Point your domain's DNS to Cloudflare

---

## 🔌 MCP CONNECTORS SETUP

### For Claude AI Sonnet 4.5

**MCP Server Configuration** (`claude-mcp-config.json`):

```json
{
  "mcpServers": {
    "mirror-worlds": {
      "command": "node",
      "args": [
        "/path/to/mcp-connectors/claude-mirror-worlds-mcp.js"
      ],
      "env": {
        "MIRROR_WORLDS_URL": "https://mirrorworlds.yourdomain.com",
        "MIRROR_WORLDS_API_KEY": "your-secret-api-key-here"
      }
    }
  }
}
```

### For Auto (Cursor AI)

**MCP Server Configuration** (`auto-mcp-config.json`):

```json
{
  "mcpServers": {
    "mirror-worlds": {
      "command": "node",
      "args": [
        "/path/to/mcp-connectors/auto-mirror-worlds-mcp.js"
      ],
      "env": {
        "MIRROR_WORLDS_URL": "https://mirrorworlds.yourdomain.com",
        "MIRROR_WORLDS_API_KEY": "your-secret-api-key-here"
      }
    }
  }
}
```

---

## 🛡️ RESILIENCE FEATURES

### Auto-Backup System

- **Daily backups** to Cloudflare R2 (object storage)
- **Point-in-time recovery** via D1 snapshots
- **Automatic failover** if primary database fails

### Monitoring & Alerts

- **Health checks** every 5 minutes
- **Alert on downtime** via email/webhook
- **Performance metrics** dashboard

### Rate Limiting

- **100 requests/minute** per IP (configurable)
- **API key required** for write operations
- **DDoS protection** via Cloudflare

---

## 📝 NEXT STEPS

1. ✅ Complete Step 1-7 above
2. ✅ Set up MCP connectors (see `MCP_CONNECTORS_SETUP.md`)
3. ✅ Test the deployment
4. ✅ Configure backups
5. ✅ Set up monitoring

---

## 🆘 TROUBLESHOOTING

### Database Connection Issues
```bash
# Check database status
wrangler d1 info mirror-worlds-db

# List databases
wrangler d1 list
```

### Worker Deployment Fails
```bash
# Check logs
wrangler tail

# Test locally
wrangler dev
```

### MCP Connector Not Working
- Verify API key is correct
- Check URL is accessible
- Review MCP server logs

---

**Signature: VULCAN-THE-FORGE-2025**  
**By: Vulcan (The Forge)**  
**For: Anthony Eric Chavez - The Keeper**





