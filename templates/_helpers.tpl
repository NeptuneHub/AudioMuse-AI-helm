{{/*
Expand the name of the chart.
*/}}
{{- define "audiomuse-ai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "audiomuse-ai.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "audiomuse-ai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "audiomuse-ai.labels" -}}
helm.sh/chart: {{ include "audiomuse-ai.chart" . }}
app.kubernetes.io/name: {{ include "audiomuse-ai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Shared secret env vars injected into both the Flask and Worker containers.
Key selection for Postgres is guarded on existingSecret being set so that
the chart-generated secret (which always uses POSTGRES_* keys) is referenced
correctly when existingSecret is empty.
*/}}
{{- define "audiomuse-ai.secretEnvVars" -}}
{{- if eq .Values.config.mediaServerType "jellyfin" }}
- name: JELLYFIN_USER_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.jellyfin.existingSecret | default (printf "%s-jellyfin" (include "audiomuse-ai.fullname" .)) }}
      key: user_id
- name: JELLYFIN_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Values.jellyfin.existingSecret | default (printf "%s-jellyfin" (include "audiomuse-ai.fullname" .)) }}
      key: api_token
{{- end }}
{{- if eq .Values.config.mediaServerType "navidrome" }}
- name: NAVIDROME_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.navidrome.existingSecret | default (printf "%s-navidrome" (include "audiomuse-ai.fullname" .)) }}
      key: NAVIDROME_USER
- name: NAVIDROME_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.navidrome.existingSecret | default (printf "%s-navidrome" (include "audiomuse-ai.fullname" .)) }}
      key: NAVIDROME_PASSWORD
{{- end }}
{{- if eq .Values.config.mediaServerType "lyrion" }}
- name: LYRION_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.lyrion.existingSecret | default (printf "%s-lyrion" (include "audiomuse-ai.fullname" .)) }}
      key: LYRION_USER
- name: LYRION_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.lyrion.existingSecret | default (printf "%s-lyrion" (include "audiomuse-ai.fullname" .)) }}
      key: LYRION_PASSWORD
{{- end }}
- name: POSTGRES_USER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.existingSecret | default (printf "%s-postgres" (include "audiomuse-ai.fullname" .)) }}
      key: {{ if .Values.postgres.existingSecret }}{{ .Values.postgres.existingSecretKeys.user | default "POSTGRES_USER" }}{{ else }}POSTGRES_USER{{ end }}
- name: POSTGRES_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.existingSecret | default (printf "%s-postgres" (include "audiomuse-ai.fullname" .)) }}
      key: {{ if .Values.postgres.existingSecret }}{{ .Values.postgres.existingSecretKeys.password | default "POSTGRES_PASSWORD" }}{{ else }}POSTGRES_PASSWORD{{ end }}
- name: POSTGRES_DB
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.existingSecret | default (printf "%s-postgres" (include "audiomuse-ai.fullname" .)) }}
      key: {{ if .Values.postgres.existingSecret }}{{ .Values.postgres.existingSecretKeys.db | default "POSTGRES_DB" }}{{ else }}POSTGRES_DB{{ end }}
{{- if eq .Values.config.aiModelProvider "GEMINI" }}
- name: GEMINI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.gemini.existingSecret | default (printf "%s-gemini" (include "audiomuse-ai.fullname" .)) }}
      key: GEMINI_API_KEY
{{- end }}
{{- if eq .Values.config.aiModelProvider "MISTRAL" }}
- name: MISTRAL_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mistral.existingSecret | default (printf "%s-mistral" (include "audiomuse-ai.fullname" .)) }}
      key: MISTRAL_API_KEY
{{- end }}
{{- if eq .Values.config.aiModelProvider "OPENAI" }}
- name: OPENAI_API_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.openai.existingSecret | default (printf "%s-openai" (include "audiomuse-ai.fullname" .)) }}
      key: OPENAI_API_KEY
{{- end }}
- name: AI_CHAT_DB_USER_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.postgres.aiChatDbExistingSecret | default (printf "%s-ai-chat-db" (include "audiomuse-ai.fullname" .)) }}
      key: AI_CHAT_DB_USER_PASSWORD
{{- end }}