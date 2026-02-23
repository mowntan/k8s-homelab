FROM alpine:3.19

# Install OpenVPN and required tools
RUN apk add --no-cache \
    openvpn \
    bash \
    iptables \
    ip6tables \
    curl \
    bind-tools

# Copy scripts
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /vpn

ENTRYPOINT ["/entrypoint.sh"]
