#!/bin/sh
set -e

# Create TUN device if not already present.
# mknod is allowed when Railway "Privileged" mode is enabled.
# If it fails (not yet privileged), continue — Railway may already provide it.
mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200 2>/dev/null || true
    chmod 600 /dev/net/tun 2>/dev/null || true
fi

if [ ! -c /dev/net/tun ]; then
    echo "ERROR: /dev/net/tun not available. The host must expose the TUN device." >&2
    exit 1
fi

# Enable IP forwarding
sysctl -w net.ipv4.ip_forward=1 2>/dev/null || echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -w net.ipv6.conf.all.forwarding=1 2>/dev/null || echo 1 > /proc/sys/net/ipv6/conf/all/forwarding

# Create state dir
mkdir -p /var/lib/tailscale /var/run/tailscale

# Start tailscaled
tailscaled \
    --state=/var/lib/tailscale/tailscaled.state \
    --socket=/var/run/tailscale/tailscaled.sock \
    &

TAILSCALED_PID=$!

# Wait for socket (up to 30s)
for i in $(seq 1 30); do
    [ -S /var/run/tailscale/tailscaled.sock ] && break
    sleep 1
done

if [ ! -S /var/run/tailscale/tailscaled.sock ]; then
    echo "ERROR: tailscaled failed to start" >&2
    exit 1
fi

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
