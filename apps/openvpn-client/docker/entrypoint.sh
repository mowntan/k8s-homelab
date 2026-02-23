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
    echo "Enabling firewall..."

    # Set default policies to ACCEPT first (we'll add specific DROP rules later)
    iptables -P INPUT ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD ACCEPT

    # Flush existing rules
    iptables -F
    iptables -X

    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Allow established and related connections
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Allow DNS to Kubernetes DNS servers
    for dns in ${DNS_SERVERS}; do
        echo "Allowing DNS to ${dns}"
        iptables -A OUTPUT -d ${dns} -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -d ${dns} -p tcp --dport 53 -j ACCEPT
    done

    # Allow all traffic on tun interfaces (VPN tunnel)
    iptables -A OUTPUT -o tun+ -j ACCEPT
    iptables -A INPUT -i tun+ -j ACCEPT

    # Allow routes for kubernetes subnets if specified
    if [ -n "${ROUTE}" ]; then
        for route in ${ROUTE}; do
            echo "Adding route exception for: ${route}"
            iptables -A OUTPUT -d ${route} -j ACCEPT
        done
    fi

    # Allow outbound UDP/TCP for VPN connection (before tunnel is up)
    iptables -A OUTPUT -p udp -j ACCEPT
    iptables -A OUTPUT -p tcp -j ACCEPT

    # Block unsolicited inbound traffic
    iptables -A INPUT -m conntrack --ctstate NEW,INVALID -j DROP

    echo "Firewall rules applied"
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
