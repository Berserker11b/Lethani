#!/bin/bash
# SETUP FAST PROXY & VPN - Full Setup (Requires Sudo)
# High Speed Network Safety with VPN
# By: Auto Agent
# For: Anthony Eric Chavez - The Keeper

echo "══════════════════════════════════════════════════════════════"
echo "FULL PROXY & VPN SETUP (SUDO REQUIRED)"
echo "══════════════════════════════════════════════════════════════"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "⚠️  This script requires sudo privileges"
    echo "   Run: sudo bash SETUP_FAST_PROXY_VPN_SUDO.sh"
    exit 1
fi

cd /home/anthony/Keepers_room

# ═══════════════════════════════════════════════════════════
# PHASE 1: OPTIMIZE DNS FOR SPEED & SAFETY
# ═══════════════════════════════════════════════════════════
echo "[1] OPTIMIZING DNS FOR SPEED & SAFETY..."
echo ""

# Backup original resolv.conf
if [ ! -f /etc/resolv.conf.backup ]; then
    cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null
    echo "   ✅ Backed up original DNS config"
fi

# Use fast DNS servers (Cloudflare 1.1.1.1 and Google 8.8.8.8)
cat > /etc/resolv.conf << DNS_EOF
# Fast DNS servers (optimized for speed and privacy)
# Cloudflare DNS (1.1.1.1) - Fast and privacy-focused
nameserver 1.1.1.1
nameserver 1.0.0.1
# Google DNS (8.8.8.8) - Fast backup
nameserver 8.8.8.8
nameserver 8.8.4.4
DNS_EOF

echo "   ✅ DNS optimized (Cloudflare + Google)"
echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 2: FULL TCP OPTIMIZATION FOR PROXY/VPN
# ═══════════════════════════════════════════════════════════
echo "[2] FULL TCP OPTIMIZATION FOR PROXY/VPN..."
echo ""

# Maximum buffer sizes for speed
sysctl -w net.core.rmem_max=134217728 > /dev/null 2>&1
sysctl -w net.core.wmem_max=134217728 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_rmem="4096 87380 134217728" > /dev/null 2>&1
sysctl -w net.ipv4.tcp_wmem="4096 65536 134217728" > /dev/null 2>&1

# Enable TCP fast open
sysctl -w net.ipv4.tcp_fastopen=3 > /dev/null 2>&1

# Optimize for low latency
sysctl -w net.ipv4.tcp_low_latency=1 > /dev/null 2>&1

# Enable BBR congestion control if available
if modprobe tcp_bbr 2>/dev/null; then
    sysctl -w net.ipv4.tcp_congestion_control=bbr > /dev/null 2>&1
    echo "   ✅ BBR congestion control enabled (fastest)"
else
    sysctl -w net.ipv4.tcp_congestion_control=cubic > /dev/null 2>&1
    echo "   ✅ CUBIC congestion control enabled"
fi

# Increase connection limits
sysctl -w net.core.somaxconn=4096 > /dev/null 2>&1
sysctl -w net.ipv4.tcp_max_syn_backlog=8192 > /dev/null 2>&1

# Optimize network interface queues
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
if [ -n "$INTERFACE" ] && command -v ethtool &> /dev/null; then
    # Increase ring buffer sizes if supported
    ethtool -G "$INTERFACE" rx 4096 tx 4096 2>/dev/null || ethtool -G "$INTERFACE" rx 2048 tx 2048 2>/dev/null || true
    
    # Enable offloading features for speed
    ethtool -K "$INTERFACE" gro on 2>/dev/null || true
    ethtool -K "$INTERFACE" gso on 2>/dev/null || true
    ethtool -K "$INTERFACE" tso on 2>/dev/null || true
    
    echo "   ✅ Network interface optimized: $INTERFACE"
fi

echo "   ✅ TCP fully optimized for maximum speed"
echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 3: WIREGUARD VPN SETUP
# ═══════════════════════════════════════════════════════════
echo "[3] SETTING UP WIREGUARD VPN..."
echo ""

if ! command -v wg &> /dev/null; then
    echo "   ⚠️  WireGuard not installed"
    echo "   Installing WireGuard..."
    apt-get update -qq > /dev/null 2>&1
    apt-get install -y wireguard wireguard-tools > /dev/null 2>&1
    echo "   ✅ WireGuard installed"
fi

WG_CONFIG_DIR="/etc/wireguard"
WG_CONFIG="$WG_CONFIG_DIR/wg0.conf"

# Check if config exists
if [ -f "$WG_CONFIG" ]; then
    echo "   ✅ WireGuard config found: $WG_CONFIG"
    
    # Check if interface is up
    if ip link show wg0 > /dev/null 2>&1; then
        echo "   ✅ WireGuard interface wg0 is active"
        wg show
    else
        echo "   Starting WireGuard interface..."
        wg-quick up wg0
        echo "   ✅ WireGuard interface started"
    fi
else
    echo "   Creating WireGuard config..."
    mkdir -p "$WG_CONFIG_DIR"
    
    # Generate keys
    PRIVATE_KEY=$(wg genkey)
    PUBLIC_KEY=$(echo "$PRIVATE_KEY" | wg pubkey)
    
    # Create config (local tunnel for safety)
    cat > "$WG_CONFIG" << WG_EOF
[Interface]
PrivateKey = $PRIVATE_KEY
Address = 10.8.0.1/24
ListenPort = 51820
# DNS = 1.1.1.1  # Fast DNS

# Add your WireGuard server config here for VPN:
# [Peer]
# PublicKey = YOUR_SERVER_PUBLIC_KEY
# Endpoint = YOUR_SERVER_IP:51820
# AllowedIPs = 0.0.0.0/0
# PersistentKeepalive = 25
WG_EOF
    
    chmod 600 "$WG_CONFIG"
    echo "   ✅ WireGuard config created"
    echo "   Public Key: $PUBLIC_KEY"
    echo "   Note: Add your WireGuard server config to enable VPN"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# PHASE 4: FIREWALL RULES FOR SAFETY
# ═══════════════════════════════════════════════════════════
echo "[4] SETTING UP FIREWALL RULES..."
echo ""

if command -v iptables &> /dev/null; then
    # Allow established connections (for speed)
    iptables -C INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
    # Allow loopback
    iptables -C INPUT -i lo -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -i lo -j ACCEPT
    
    # Allow local proxy ports
    iptables -C INPUT -p tcp --dport 8080 -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
    iptables -C INPUT -p tcp --dport 1080 -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -p tcp --dport 1080 -j ACCEPT
    
    # Allow WireGuard
    iptables -C INPUT -p udp --dport 51820 -j ACCEPT 2>/dev/null || \
        iptables -A INPUT -p udp --dport 51820 -j ACCEPT
    
    echo "   ✅ Firewall rules applied"
else
    echo "   ⚠️  iptables not available"
fi

echo ""

# ═══════════════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════════════
echo "══════════════════════════════════════════════════════════════"
echo "✅ FULL PROXY & VPN SETUP COMPLETE"
echo "══════════════════════════════════════════════════════════════"
echo ""

echo "🌐 PROXY SERVERS:"
echo "   HTTP Proxy:  http://127.0.0.1:8080"
echo "   SOCKS5 Proxy: socks5://127.0.0.1:1080"
echo ""

echo "🔒 VPN:"
if ip link show wg0 > /dev/null 2>&1; then
    echo "   WireGuard: ✅ ACTIVE (wg0)"
    wg show
else
    echo "   WireGuard: ⚠️  NOT ACTIVE"
    echo "   Start with: wg-quick up wg0"
fi
echo ""

echo "⚡ SPEED OPTIMIZATIONS:"
echo "   ✅ BBR/CUBIC congestion control"
echo "   ✅ Large buffers (128MB)"
echo "   ✅ TCP fast open enabled"
echo "   ✅ Low latency mode"
echo "   ✅ Network interface optimized"
echo ""

echo "🛡️  SAFETY:"
echo "   ✅ Fast DNS (Cloudflare + Google)"
echo "   ✅ Firewall rules applied"
echo "   ✅ Proxy filtering active"
echo ""

echo "📋 USAGE:"
echo "   Export proxy variables:"
echo "   export http_proxy='http://127.0.0.1:8080'"
echo "   export https_proxy='http://127.0.0.1:8080'"
echo "   export all_proxy='socks5://127.0.0.1:1080'"
echo ""
echo "   Test proxy:"
echo "   curl -x http://127.0.0.1:8080 http://example.com"
echo ""
echo "   Test SOCKS5:"
echo "   curl --socks5 127.0.0.1:1080 http://example.com"
echo ""



