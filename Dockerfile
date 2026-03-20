FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install Tailscale from its own apt repo — always latest stable.
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates curl iptables iproute2 procps && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.noarmor.gpg \
      | tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null && \
    curl -fsSL https://pkgs.tailscale.com/stable/debian/bookworm.tailscale-keyring.list \
      | tee /etc/apt/sources.list.d/tailscale.list && \
    apt-get update && apt-get install -y tailscale && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/tailscale /var/lib/tailscale

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
