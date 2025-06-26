# AudioMuse-AI Helm Chart

This repository contains the Helm chart for deploying the [AudioMuse-AI app](https://github.com/NeptuneHub/AudioMuse-AI).

## Installation

```bash
helm repo add audiomuse-ai https://NeptuneHub.github.io/AudioMuse-AI-helm
helm repo update
helm install my-audiomuse audiomuse-ai/audiomuse-ai \
  --namespace test \
  --create-namespace \
  --values my-custom-values.yaml
```

## Minimum Required `my-custom-values.yaml`

Here is a minimal configuration example for your `my-custom-values.yaml`:

```yaml
postgres:
  user: "audiomuse"
  password: "audiomusepassword" # IMPORTANT: Change this for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change this for production

# IMPORTANT: Set the correct Jellyfin values
jellyfin:
  userId: "0e45c44b3e2e4da7a2be11a72a1c8575"
  token: "e0b8c325bc1b426c81922b90c0aa2ff1"
  url: "http://jellyfin.192.168.3.131.nip.io:8087"

gemini:
  apiKey: "YOUR_GEMINI_API_KEY_HERE" # IMPORTANT: Change this for production

# AI Configuration
# You can use "OLLAMA", "GEMINI", or "NONE" (some features will be disabled if NONE)
config:
  aiModelProvider: "NONE" # Options: "GEMINI", "OLLAMA", or "NONE"
  ollamaServerUrl: "http://192.168.3.15:11434/api/generate"
  ollamaModelName: "mistral:7b"
  geminiModelName: "gemini-1.5-flash-latest"
  aiChatDbUserName: "ai_user" # Must match postgres.aiChatDbUser
```

## Additional Configuration

For the full list of supported configuration values, refer to the [values.yaml file](https://github.com/NeptuneHub/AudioMuse-AI-helm/blob/main/values.yaml).

For detailed documentation on each environment variable, visit the [AudioMuse-AI main repository](https://github.com/NeptuneHub/AudioMuse-AI).
