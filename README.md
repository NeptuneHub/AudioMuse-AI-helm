![GitHub license](https://img.shields.io/github/license/neptunehub/AudioMuse-AI-helm.svg)
![Latest Tag](https://img.shields.io/github/v/tag/neptunehub/AudioMuse-AI-helm?label=latest-tag)
![Media Server Support: Jellyfin 10.11.0, Navidrome 0.58.0, Lyrion](https://img.shields.io/badge/Media%20Server-Jellyfin%2010.11.0%2C%20Navidrome%200.58.0%2C%20Lyrion-blue?style=flat-square&logo=server&logoColor=white)

# AudioMuse-AI Helm Chart

<p align="center">
  <img src="https://github.com/NeptuneHub/AudioMuse-AI/blob/main/screenshot/audiomuseai.png?raw=true" alt="AudioMuse-AI Logo" width="480">
</p>

This repository contains the Helm chart for deploying the [AudioMuse-AI app](https://github.com/NeptuneHub/AudioMuse-AI).

**The full list of AudioMuse-AI related repositories:**
  > * [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI): the core application, running Flask and Worker containers;
  > * [AudioMuse-AI Helm Chart](https://github.com/NeptuneHub/AudioMuse-AI-helm): Helm chart for easy installation on Kubernetes;
  > * [AudioMuse-AI Plugin for Jellyfin](https://github.com/NeptuneHub/audiomuse-ai-plugin): Jellyfin Plugin;
  > * [AudioMuse-AI Plugin for Navidrome](https://github.com/NeptuneHub/AudioMuse-AI-NV-plugin): Navidrome Plugin;
  > * [AudioMuse-AI MusicServer](https://github.com/NeptuneHub/AudioMuse-AI-MusicServer): Open Subsonic-compatible Music Server with integrated sonic functionality.

## Table of Contents

- [What this chart manages](#what-this-chart-manages)
- [Installation](#installation)
- [Minimum Required Configuration](#minimum-required-my-custom-valuesyaml)
- [External PostgreSQL (e.g. CloudNativePG)](#external-postgresql-eg-cloudnativepg)
- [External Redis](#external-redis)
- [Bring Your Own Secrets (`existingSecret`)](#bring-your-own-secrets-existingsecret)
- [Ingress](#ingress)
- [Additional Configuration](#additional-configuration)
- [How to Uninstall](#how-to-uninstall)

---

## What this chart manages

This chart deploys the AudioMuse-AI infrastructure: **PostgreSQL, Redis, Flask, and Worker**. Once installed, open the app UI and complete the **setup wizard** to configure your media server, authentication, and AI provider — those settings live in the app's database, not in `values.yaml`.

---

## Installation

```bash
helm repo add audiomuse-ai https://NeptuneHub.github.io/AudioMuse-AI-helm
helm repo update
helm install my-audiomuse audiomuse-ai/audiomuse-ai \
  --namespace playlist \
  --create-namespace \
  --values my-custom-values.yaml
```

---

## Minimum Required `my-custom-values.yaml`

For a default install (built-in PostgreSQL and Redis), the only required override is the PostgreSQL password:

```yaml
postgres:
  password: "your-strong-password"   # change for production

timezone: "Europe/Rome"               # optional, defaults to UTC
```

---

## External PostgreSQL (e.g. CloudNativePG)

Set `postgres.enabled: false` and supply the external host. The built-in PostgreSQL Deployment and PVC will not be created.

```yaml
postgres:
  enabled: false
  external:
    host: "audiomuse-postgresql-rw"   # service name of the external PG instance
    port: 5432
  # Credentials — set directly or use existingSecret (see below)
  user: "audiomuse"
  password: "YOUR-PASSWORD"
  db: "audiomusedb"
```

> **Note:** If you omit `postgres.external.host` while `postgres.enabled: false`, `helm template`/`helm install` will fail with a clear error message.

### Using a CloudNativePG-managed secret

CloudNativePG generates a secret whose keys are `username`, `password`, and `dbname`. Point the chart at it directly:

```yaml
postgres:
  enabled: false
  external:
    host: "audiomuse-postgresql-rw"
    port: 5432
  existingSecret: "audiomuse-postgresql-app"   # CNPG-generated secret name
  existingSecretKeys:
    user: "username"
    password: "password"
    db: "dbname"
```

---

## External Redis

Set `redis.enabled: false` and supply a full Redis URL. The built-in Redis Deployment and Service will not be created.

```yaml
redis:
  enabled: false
  external:
    url: "redis://my-redis-cluster:6379/0"
```

> **Note:** If you omit `redis.external.url` while `redis.enabled: false`, `helm template`/`helm install` will fail with a clear error message.

---

## Bring Your Own Secrets (`existingSecret`)

PostgreSQL credentials can be sourced from an existing Kubernetes Secret managed by tools like Sealed Secrets, External Secrets Operator, or Vault. When `postgres.existingSecret` is set, the chart will **not** create its own PostgreSQL Secret.

```yaml
postgres:
  existingSecret: "my-postgres-secret"
  existingSecretKeys:
    user: "POSTGRES_USER"      # key name inside the secret
    password: "POSTGRES_PASSWORD"
    db: "POSTGRES_DB"
```

---

## Ingress

By default Ingress is **disabled** and the Flask service is exposed as `LoadBalancer`, so you can reach the app at `publicip:8000`. To use Ingress instead (example uses Let's Encrypt):

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: audiomuse.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: audiomuse-tls
      hosts:
        - audiomuse.example.com
```

---

## Additional Configuration

For the full list of supported configuration values, refer to the [values.yaml file](https://github.com/NeptuneHub/AudioMuse-AI-helm/blob/main/values.yaml).

For detailed documentation on each application setting (media server, auth, AI providers, clustering), visit the [AudioMuse-AI main repository](https://github.com/NeptuneHub/AudioMuse-AI) — those settings are configured through the in-app setup wizard, not through the chart.

To check the chart version that matches the AudioMuse-AI version you want to install:

```bash
helm search repo audiomuse-ai
```

Example output:

```
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
audiomuse-ai/audiomuse-ai       1.1.5           1.1.3           A Helm chart for deploying the AudioMuse-AI app...
```

---

## How to Uninstall

If you installed as `my-audiomuse` in the `playlist` namespace:

```bash
helm uninstall my-audiomuse -n playlist
```
