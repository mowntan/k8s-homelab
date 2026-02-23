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

# Get DNS servers from resolv.conf before we potentially restrict network access
DNS_SERVERS=$(awk '/^nameserver/ {print $2}' /etc/resolv.conf | head -n 3)
echo "Using DNS servers: ${DNS_SERVERS}"

# Setup firewall rules if FIREWALL is enabled
if [ "${FIREWALL}" = "on" ]; then
    echo "Enabling firewall..."

    # Allow loopback
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    # Allow established connections
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

    # Allow DNS to Kubernetes DNS servers
    for dns in ${DNS_SERVERS}; do
        echo "Allowing DNS to ${dns}"
        iptables -A OUTPUT -d ${dns} -p udp --dport 53 -j ACCEPT
        iptables -A OUTPUT -d ${dns} -p tcp --dport 53 -j ACCEPT
    done

    # Allow VPN traffic
    iptables -A OUTPUT -o tun+ -j ACCEPT
    iptables -A INPUT -i tun+ -j ACCEPT

    # Allow routes for kubernetes subnets if specified
    if [ -n "${ROUTE}" ]; then
        for route in ${ROUTE}; do
            echo "Adding route exception for: ${route}"
            iptables -A OUTPUT -d ${route} -j ACCEPT
        done
    fi

    # Allow outbound connections (needed for initial VPN connection)
    iptables -A OUTPUT -p udp -j ACCEPT
    iptables -A OUTPUT -p tcp -j ACCEPT

    # Block inbound by default
    iptables -P INPUT DROP
    iptables -P FORWARD DROP

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
