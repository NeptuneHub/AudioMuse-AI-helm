# AudioMuse-AI-helm
AudioMuse-AI helm chart: STILL UNDER CONSTRUCTION

# How to install
```
helm repo add audiomuse-ai https://NeptuneHub.github.io/AudioMuse-AI-helm
helm repo update
helm install my-audiomuse audiomuse-ai/audiomuse-ai --namespace test --create-namespace --values my-custom-values.yaml
```

Where as minimum value for **my-custom-values.yaml** we suggest to configure this:
```
postgres:
  user: "audiomuse"
  password: "audiomusepassword" # IMPORTANT: Change this for production
  aiChatDbUser: "ai_user"
  aiChatDbUserPassword: "ChangeThisSecurePassword123!" # IMPORTANT: Change this for production

# IMPORTANT: Put here you jellyfin correct value
jellyfin:
  userId: "0e45c44b3e2e4da7a2be11a72a1c8575"
  token: "e0b8c325bc1b426c81922b90c0aa2ff1"
  url: "http://jellyfin.192.168.3.131.nip.io:8087"

gemini:
  apiKey: "YOUR_GEMINI_API_KEY_HERE" # IMPORTANT: Change this for production

# IMPORTANT: Put here your AI configuration. You can decide to use ollama OR Gemini or if you prefear NONE to don't use it at all but some functionality will be unaviable.
config:
  aiModelProvider: "NONE" # Or "GEMINI", "OLLAMA", etc.
  ollamaServerUrl: "http://192.168.3.15:11434/api/generate"
  ollamaModelName: "mistral:7b"
  geminiModelName: "gemini-1.5-flash-latest"
  aiChatDbUserName: "ai_user" # Corresponds to postgres.aiChatDbUser
```
