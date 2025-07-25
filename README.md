![GitHub license](https://img.shields.io/github/license/neptunehub/AudioMuse-AI-helm.svg)
![Latest Tag](https://img.shields.io/github/v/tag/neptunehub/AudioMuse-AI-helm?label=latest-tag)
![Media Server Support: Jellyfin 10.10.7, Navidrome 0.57.0](https://img.shields.io/badge/Media%20Server-Jellyfin%2010.10.7%2C%20Navidrome%200.57.0-blue?style=flat-square&logo=server&logoColor=white)

# AudioMuse-AI Helm Chart

<p align="center">
  <img src="https://github.com/NeptuneHub/AudioMuse-AI/blob/main/screenshot/audiomuseai.png?raw=true" alt="AudioMuse-AI Logo" width="480">
</p>

This repository contains the Helm chart for deploying the [AudioMuse-AI app](https://github.com/NeptuneHub/AudioMuse-AI).

**The full list or AudioMuse-AI related repository are:** 
  > * [AudioMuse-AI](https://github.com/NeptuneHub/AudioMuse-AI): the core application, it run Flask and Worker containers to actually run all the feature;
  > * [AudioMuse-AI Helm Chart](https://github.com/NeptuneHub/AudioMuse-AI-helm): helm chart for easy installation on Kubernetes;
  > * [AudioMuse-AI Plugin for Jellyfin](https://github.com/NeptuneHub/audiomuse-ai-plugin): Jellyfin Plugin.

## Installation

```bash
helm repo add audiomuse-ai https://NeptuneHub.github.io/AudioMuse-AI-helm
helm repo update
helm install my-audiomuse audiomuse-ai/audiomuse-ai \
  --namespace playlist \
  --create-namespace \
  --values my-custom-values.yaml
```

## Minimum Required `my-custom-values.yaml`

Here is a minimal configuration example for your `my-custom-values.yaml` for **Jellyfin**:

```yaml
postgres:
  user: "audiomuse"
  password: "audiomusepassword" # IMPORTANT: Change this for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change this for production

# IMPORTANT: Set the correct Jellyfin values
jellyfin:
  userId: "YOUR-USER-ID"
  token: "YOUR-API-TOKEN"
  url: "http://jellyfin.192.168.3.131.nip.io:8087"

gemini:
  apiKey: "YOUR_GEMINI_API_KEY_HERE" # IMPORTANT: Change this for production

# AI Configuration
# You can use "OLLAMA", "GEMINI", or "NONE" (some features will be disabled if NONE)
config:
  mediaServerType: "jellyfin"
  aiModelProvider: "NONE" # Options: "GEMINI", "OLLAMA", or "NONE"
  ollamaServerUrl: "http://192.168.3.15:11434/api/generate"
  ollamaModelName: "mistral:7b"
  geminiModelName: "gemini-1.5-flash-latest"
  aiChatDbUserName: "ai_user" # Must match postgres.aiChatDbUser
```

Here is a minimal configuration example for your `my-custom-values.yaml` for **Navidrome**:

```yaml
postgres:
  user: "audiomuse"
  password: "audiomusepassword" # IMPORTANT: Change this for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change this for production

# IMPORTANT: Set the correct Navidrome values
navidrome:
  user: "YOUR-USER"
  password: "YOUR-PASSWORD"
  url: "http://your_navidrome_url:4533"

gemini:
  apiKey: "YOUR_GEMINI_API_KEY_HERE" # IMPORTANT: Change this for production

# AI Configuration
# You can use "OLLAMA", "GEMINI", or "NONE" (some features will be disabled if NONE)
config:
  mediaServerType: "navidrome"
  aiModelProvider: "NONE" # Options: "GEMINI", "OLLAMA", or "NONE"
  ollamaServerUrl: "http://192.168.3.15:11434/api/generate"
  ollamaModelName: "mistral:7b"
  geminiModelName: "gemini-1.5-flash-latest"
  aiChatDbUserName: "ai_user" # Must match postgres.aiChatDbUser
```

## Additional Configuration

For the full list of supported configuration values, refer to the [values.yaml file](https://github.com/NeptuneHub/AudioMuse-AI-helm/blob/main/values.yaml).

For detailed documentation on each environment variable, visit the [AudioMuse-AI main repository](https://github.com/NeptuneHub/AudioMuse-AI).

To be sure that you have the last updated chart version that match with the version of AudioMuse-AI that you want to install, just run this command:
```
helm search repo audiomuse-ai
```

You will have a result like this where you can check the **APP VERSION**:  (this is only an example)
```
NAME                            CHART VERSION   APP VERSION     DESCRIPTION
audiomuse-ai/audiomuse-ai       1.0.2           0.5.0-beta      A Helm chart for deploying the AudioMuse-AI app...
```

## How to uninstall
It's helm, if you followed the above instraction you had deployed my-audiomuse in playlist namespace, to to remove it just run this command:

```
helm uninstall my-audiomuse -n test
```
