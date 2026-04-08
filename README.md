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

- [Installation](#installation)
- [Minimum Required Configuration](#minimum-required-my-custom-valuesyaml)
- [External PostgreSQL (e.g. CloudNativePG)](#external-postgresql-eg-cloudnativepg)
- [External Redis](#external-redis)
- [Bring Your Own Secrets (`existingSecret`)](#bring-your-own-secrets-existingsecret)
- [Ingress](#ingress)
- [Security Context](#security-context)
- [Service Account](#service-account)
- [Additional Configuration](#additional-configuration)
- [How to Uninstall](#how-to-uninstall)

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

Only set values for the media server and AI provider you actually use. Secrets for inactive integrations are **not** created by the chart.

### Jellyfin

```yaml
postgres:
  user: "audiomuse"
  password: "audiomusepassword"           # IMPORTANT: Change for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change for production

jellyfin:
  userId: "YOUR-USER-ID"
  token: "YOUR-API-TOKEN"
  url: "http://jellyfin.example.com:8087"

config:
  mediaServerType: "jellyfin"
  aiModelProvider: "NONE" # Options: "OPENAI", "GEMINI", "OLLAMA", "MISTRAL", or "NONE"
  aiChatDbUserName: "ai_user"

auth:
  enabled: true
  user: "YOUR_AUDIOMUSE_USER"
  password: "YOUR_AUDIOMUSE_PASSWORD"
  apiToken: "YOUR_API_TOKEN"
```

### Navidrome

```yaml
postgres:
  user: "audiomuse"
  password: "audiomusepassword"           # IMPORTANT: Change for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change for production

navidrome:
  user: "YOUR-USER"
  password: "YOUR-PASSWORD"
  url: "http://your_navidrome_url:4533"

config:
  mediaServerType: "navidrome"
  aiModelProvider: "NONE"
  aiChatDbUserName: "ai_user"

auth:
  enabled: true
  user: "YOUR_AUDIOMUSE_USER"
  password: "YOUR_AUDIOMUSE_PASSWORD"
  apiToken: "YOUR_API_TOKEN"
```

### Lyrion

```yaml
postgres:
  user: "audiomuse"
  password: "audiomusepassword"           # IMPORTANT: Change for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change for production

lyrion:
  user: "YOUR-USER"
  password: "YOUR-PASSWORD"
  url: "http://YOUR-LYRION-URL"

config:
  mediaServerType: "lyrion"
  aiModelProvider: "NONE"
  aiChatDbUserName: "ai_user"

auth:
  enabled: true
  user: "YOUR_AUDIOMUSE_USER"
  password: "YOUR_AUDIOMUSE_PASSWORD"
  apiToken: "YOUR_API_TOKEN"
```

### Enabling an AI provider

Set only the key for the provider you want. The chart will only create that provider's secret.

```yaml
config:
  aiModelProvider: "GEMINI"   # or "OPENAI", "MISTRAL", "OLLAMA"

gemini:
  apiKey: "YOUR_GEMINI_API_KEY_HERE"

# openai:
#   apiKey: "YOUR_OPENAI_API_KEY_HERE"

# mistral:
#   apiKey: "YOUR_MISTRAL_API_KEY_HERE"

# config:
#   mistralModelName: "ministral-3b-latest"
#   ollamaServerUrl: "http://192.168.3.15:11434/api/generate"
#   ollamaModelName: "mistral:7b"
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
  aiChatDbUserPassword: "ChangeThisSecurePassword123!"
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
  aiChatDbUserPassword: "ChangeThisSecurePassword123!"
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

Every integration supports `existingSecret` so you can manage credentials with an external secrets manager (Sealed Secrets, External Secrets Operator, Vault, etc.). When set, the chart will **not** create its own Secret for that integration.

```yaml
postgres:
  existingSecret: "my-postgres-secret"
  existingSecretKeys:
    user: "POSTGRES_USER"      # key name inside the secret
    password: "POSTGRES_PASSWORD"
    db: "POSTGRES_DB"
  aiChatDbExistingSecret: "my-ai-chat-db-secret"  # must contain key: AI_CHAT_DB_USER_PASSWORD

jellyfin:
  existingSecret: "my-jellyfin-secret"   # must contain keys: user_id, api_token

navidrome:
  existingSecret: "my-navidrome-secret"  # must contain keys: NAVIDROME_USER, NAVIDROME_PASSWORD

lyrion:
  existingSecret: "my-lyrion-secret"     # must contain keys: LYRION_USER, LYRION_PASSWORD

auth:
  existingSecret: "my-auth-secret"       # must contain keys: AUDIOMUSE_USER, AUDIOMUSE_PASSWORD, API_TOKEN

openai:
  existingSecret: "my-openai-secret"     # must contain key: OPENAI_API_KEY

gemini:
  existingSecret: "my-gemini-secret"     # must contain key: GEMINI_API_KEY

mistral:
  existingSecret: "my-mistral-secret"    # must contain key: MISTRAL_API_KEY
```

---

## Ingress

The chart ships an Ingress template that is **disabled by default**. The Flask service defaults to `LoadBalancer` so by default you can reach normally the service to `publicip:8000`. 
This heml chart also provide an optional Ingress controller that you can anbled adding the below example in your `values.yaml`, this example assume the use of letsencrypy certificate.

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

## Security Context

Pods run as UID/GID 1000 by default (non-root). You can override either context:

```yaml
podSecurityContext:
  runAsUser: 1000   # Verify this matches the UID in the container image
  runAsGroup: 1000
  fsGroup: 1000

containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: false   # app writes to /app/temp_audio
  runAsNonRoot: true
  capabilities:
    drop: ["ALL"]
```

To run as root (opt-in, not recommended for production):

```yaml
podSecurityContext:
  runAsUser: 0
  runAsGroup: 0
  fsGroup: 0

containerSecurityContext:
  allowPrivilegeEscalation: true
  runAsNonRoot: false
  capabilities: {}
```

---

## Additional Configuration

For the full list of supported configuration values, refer to the [values.yaml file](https://github.com/NeptuneHub/AudioMuse-AI-helm/blob/main/values.yaml).

For detailed documentation on each environment variable, visit the [AudioMuse-AI main repository](https://github.com/NeptuneHub/AudioMuse-AI).

To check the chart version that matches the AudioMuse-AI version you want to install:

```bash
helm search repo audiomuse-ai
```

Example output:

```
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
audiomuse-ai/audiomuse-ai       1.1.0           0.9.2           A Helm chart for deploying the AudioMuse-AI app...
```

---

## How to Uninstall

If you installed as `my-audiomuse` in the `playlist` namespace:

```bash
helm uninstall my-audiomuse -n playlist
```
