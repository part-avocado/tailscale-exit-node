FROM alpine:3.19

RUN apk add --no-cache tailscale iptables ip6tables iproute2

COPY start.sh /start.sh
RUN chmod +x /start.sh && mkdir -p /var/run/tailscale

ENTRYPOINT ["/start.sh"]
