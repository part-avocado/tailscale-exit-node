#!/bin/sh
set -e

# Create TUN device if needed (requires privileged mode in Railway)
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
    chmod 600 /dev/net/tun
fi

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1   2>/dev/null || echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

# Create state dir
mkdir -p /var/lib/tailscale

# Start tailscaled
tailscaled \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    &

TAILSCALED_PID=$!

# Wait for socket
for i in $(seq 1 30); do
    [ -S /var/run/tailscale/tailscaled.sock ] && break
    sleep 1
done

# Bring up Tailscale as exit node
tailscale up \
    --authkey="${TS_AUTHKEY}" \
    --advertise-exit-node \
    --hostname="${TS_HOSTNAME:-railway-exit-node}" \
    --accept-dns=false

echo "Tailscale exit node running. Status:"
tailscale status

# Keep container alive
wait $TAILSCALED_PID
