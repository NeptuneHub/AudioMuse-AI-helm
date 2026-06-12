![GitHub license](https://img.shields.io/github/license/neptunehub/AudioMuse-AI-helm.svg)
![Latest Tag](https://img.shields.io/github/v/tag/neptunehub/AudioMuse-AI-helm?label=latest-tag)
![Media Server Support: Jellyfin 10.11.0, Navidrome 0.58.0, Lyrion](https://img.shields.io/badge/Media%20Server-Jellyfin%2010.11.0%2C%20Navidrome%200.58.0%2C%20Lyrion-blue?style=flat-square&logo=server&logoColor=white)

# AudioMuse-AI Helm Chart

<p align="center">
  <img src="https://github.com/NeptuneHub/AudioMuse-AI/blob/main/screenshot/audiomuseai.png?raw=true" alt="AudioMuse-AI Logo" width="480">
</p>

This repository contains the official Helm chart for installing [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI) on K3S. AudioMuse-AI is an open-source music analysis and automatic playlist generator that integrates with Jellyfin, Navidrome, and Lyrion media servers.

**The full list of AudioMuse-AI related repositories:**
- [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI) — the core application, running Flask and Worker containers
- [AudioMuse-AI Helm Chart](https://github.com/NeptuneHub/AudioMuse-AI-helm) — Helm chart for easy installation on Kubernetes (this repo)
- [AudioMuse-AI Plugin for Jellyfin](https://github.com/NeptuneHub/audiomuse-ai-plugin) — Jellyfin plugin
- [AudioMuse-AI Plugin for Navidrome](https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin) — Navidrome plugin
- [AudioMuse-AI MusicServer](https://github.com/NeptuneHub/AudioMuse-AI-MusicServer) — Open Subsonic-compatible music server with integrated sonic functionality

## Table of Contents

- [What this chart deploys](#what-this-chart-deploys)
- [Quick install (defaults)](#quick-install-defaults)
- [Custom install (recommended)](#custom-install-recommended)
- [Choosing the AudioMuse-AI version](#choosing-the-audiomuse-ai-version)
- [Advanced configuration](#advanced-configuration)
- [How to Uninstall](#how-to-uninstall)

## What this chart deploys

PostgreSQL, Redis, Flask, and Worker. After install, open the app UI and complete the **setup wizard** to configure your media server, authentication, and AI provider — those settings live in the app database, not in `values.yaml`.

## Quick install (defaults)

```bash
helm repo add audiomuse-ai https://NeptuneHub.github.io/AudioMuse-AI-helm
helm repo update

helm install my-audiomuse audiomuse-ai/audiomuse-ai \
  --namespace audiomuse \
  --create-namespace
```

The app is reachable at `<LoadBalancer-IP>:8000` once pods are ready.

> **Note:** the default PostgreSQL password is `audiomusepassword`. Fine for trying it out — must be changed for production (see below).

## Custom install (recommended)

Create `my-values.yaml`:

```yaml
postgres:
  password: "your-strong-postgres-password"

timezone: "Europe/Rome"   # optional, defaults to "UTC"
```

> The built-in Redis has no auth (cluster-internal only). If you use an external Redis with auth, include the password in `redis.external.url` — see [Advanced configuration](#advanced-configuration).

Install with those values:

```bash
helm install my-audiomuse audiomuse-ai/audiomuse-ai \
  --namespace audiomuse \
  --create-namespace \
  --values my-values.yaml
```

## Choosing the AudioMuse-AI version

By default the chart pulls **`latest`** from `ghcr.io/neptunehub/audiomuse-ai`. To pin a specific version, add `image.tag` to your values:

```yaml
image:
  tag: "1.1.3"
```

Available tags: https://github.com/NeptuneHub/AudioMuse-AI/pkgs/container/audiomuse-ai

## Advanced configuration

See [`values.yaml`](values.yaml) for the full reference. Common overrides:

- **External PostgreSQL** (e.g. CloudNativePG): `postgres.enabled: false` + `postgres.external.host: ...`
- **External Redis**: `redis.enabled: false` + `redis.external.url: "redis://user:pass@host:6379/0"`
- **Use an existing Kubernetes Secret** for postgres credentials: `postgres.existingSecret: "my-secret"` (with `existingSecretKeys` to remap CNPG-style key names)
- **Ingress**: set `ingress.enabled: true` with `hosts` and `tls` per the example in `values.yaml`

## How to Uninstall

```bash
helm uninstall my-audiomuse -n audiomuse
```

To also remove the namespace and its persistent volume claims:

```bash
kubectl delete namespace audiomuse
```

## Code Mirror
AudioMuse-AI Helm Chart repository code is mirrored here:
- https://codeberg.org/NeptuneHub/AudioMuse-AI-helm

DO **NOT** USE MIRROR TO RAISE ISSUE, PR OTHER ACTION DIFFERENT FROM GET THE CODE
