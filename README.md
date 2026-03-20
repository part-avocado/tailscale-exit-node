# Tailscale Exit Node on Railway

A minimal Tailscale exit node running on Railway (US East — Boston-adjacent).

## How it works

The container runs `tailscaled` + `tailscale up --advertise-exit-node` inside Alpine Linux. Railway deploys it from this GitHub repo.

---

## Setup

### 1. Get a Tailscale auth key

1. Go to [Tailscale Admin → Settings → Keys](https://login.tailscale.com/admin/settings/keys)
2. Click **Generate auth key**
3. Check **Reusable** (so Railway can redeploy without a new key)
4. Optionally check **Pre-authorized** to skip manual approval
5. Copy the key (starts with `tskey-auth-...`)

### 2. Deploy to Railway

1. Go to [railway.app](https://railway.app) and create a new project
2. Click **Deploy from GitHub repo** → connect your GitHub account → select `tailscale-exit-node`
3. Railway will detect the `Dockerfile` and start building

### 3. Add environment variables in Railway

In your Railway service → **Variables**, add:

| Variable | Value |
|----------|-------|
| `TS_AUTHKEY` | `tskey-auth-...` (your auth key from step 1) |
| `TS_HOSTNAME` | `railway-exit-node` (optional, any name you want) |

### 4. Enable Privileged mode in Railway

The container needs kernel-level access to create a TUN device:

1. In your Railway service → **Settings** → scroll to **Networking**
2. Enable **Privileged** mode

Then redeploy.

### 5. Approve the exit node in Tailscale Admin

Unless you used a pre-authorized key, approve the node:

1. Go to [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines)
2. Find `railway-exit-node` → click `...` → **Edit route settings**
3. Enable **Use as exit node**

### 6. Use the exit node

On any of your Tailscale devices:

- **macOS/iOS/Windows**: Tailscale menu → **Exit Node** → select `railway-exit-node`
- **Linux CLI**: `tailscale up --exit-node=railway-exit-node`

---

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `TS_AUTHKEY` | Yes | Tailscale auth key |
| `TS_HOSTNAME` | No | Hostname shown in Tailscale admin (default: `railway-exit-node`) |

---

## Troubleshooting

**Container crashes on start** — Make sure Privileged mode is enabled in Railway service settings.

**Exit node not appearing** — Check Railway deploy logs. The auth key may be expired or single-use.

**Can't approve exit node** — Enable it manually in [Tailscale Admin → Machines](https://login.tailscale.com/admin/machines) or regenerate the key with "Pre-authorized" checked.
