# Tailscale Exit Node on Fly.io

A minimal Tailscale exit node deployed on Fly.io (US East — `iad`, Washington DC).

Fly.io runs full Firecracker microVMs (not restricted containers), so `/dev/net/tun` and network capabilities are available without any special flags.

---

## Setup

### 1. Get a Tailscale auth key

1. Go to [Tailscale Admin → Settings → Keys](https://login.tailscale.com/admin/settings/keys)
2. Click **Generate auth key**
3. Check **Reusable** (so Fly.io can redeploy without a new key)
4. Optionally check **Pre-authorized** to skip the manual approval step
5. Copy the key (starts with `tskey-auth-...`)

### 2. Install flyctl and log in

```bash
brew install flyctl   # or: curl -L https://fly.io/install.sh | sh
fly auth login
```

### 3. Create the Fly.io app

```bash
fly apps create tailscale-exit-node   # choose any globally unique name
```

Then update the `app` field in `fly.toml` to match.

### 4. Set your Tailscale auth key as a secret

```bash
fly secrets set TS_AUTHKEY=tskey-auth-xxxxxxxxxxxx
# optional:
fly secrets set TS_HOSTNAME=fly-exit-node
```

### 5. Deploy

```bash
fly deploy
```

That's it. Watch the logs with `fly logs`.

### 6. Approve the exit node in Tailscale Admin

Unless you used a pre-authorized key, you still need to enable the route:

1. Go to [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines)
2. Find your node → `...` → **Edit route settings** → enable **Use as exit node**

### 7. Use it

- **macOS/iOS/Windows**: Tailscale menu → Exit Node → select your node
- **Linux**: `tailscale up --exit-node=fly-exit-node`

---

## Environment variables / secrets

| Variable | Required | Description |
|----------|----------|-------------|
| `TS_AUTHKEY` | Yes | Tailscale auth key (`fly secrets set`) |
| `TS_HOSTNAME` | No | Hostname shown in Tailscale admin (default: `railway-exit-node`) |

---

## Redeploying

Push to `main` or run `fly deploy` from the repo directory.

To check status: `fly status` or `fly logs`
