#!/bin/bash
set -e

# Function to cleanup on exit
cleanup() {
    echo "Shutting down..."
    if [ -f /vpn/down.sh ]; then
        bash /vpn/down.sh
    fi
}

trap cleanup SIGTERM SIGINT

# Debug: Show resolv.conf content
echo "=== /etc/resolv.conf content ==="
cat /etc/resolv.conf
echo "================================"

# Get DNS servers from resolv.conf before we potentially restrict network access
DNS_SERVERS=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | head -n 3)
echo "Extracted DNS servers: ${DNS_SERVERS}"

# Test DNS resolution before applying firewall rules
echo "Testing DNS resolution before firewall..."
nslookup yul-002.vpn.privado.io || echo "DNS resolution failed before firewall"

# Setup firewall rules if FIREWALL is enabled
if [ "${FIREWALL}" = "on" ]; then
    echo "Firewall requested, but currently disabled for debugging"
    echo "To enable firewall, the implementation needs NET_ADMIN capability"
    # Uncomment below when firewall is needed
    # echo "Enabling firewall..."
    # Set default policies and rules here
fi

# Start OpenVPN
echo "Starting OpenVPN..."
openvpn --config /vpn/vpn.conf --auth-user-pass /vpn/auth &
OPENVPN_PID=$!

# Wait for VPN connection
sleep 5

# Run up script if it exists
if [ -f /vpn/up.sh ]; then
    echo "Running up script..."
    bash /vpn/up.sh
fi

echo "OpenVPN started successfully"

# Wait for OpenVPN process
wait $OPENVPN_PID
