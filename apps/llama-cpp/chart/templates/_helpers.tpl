{{/*
Expand the name of the chart.
*/}}
{{- define "llama-cpp.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "llama-cpp.fullname" -}}
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
Create chart label.
*/}}
{{- define "llama-cpp.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "llama-cpp.labels" -}}
helm.sh/chart: {{ include "llama-cpp.chart" . }}
{{ include "llama-cpp.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for the coordinator Deployment.
*/}}
{{- define "llama-cpp.selectorLabels" -}}
app.kubernetes.io/name: {{ include "llama-cpp.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for the RPC worker DaemonSet.
*/}}
{{- define "llama-cpp.rpcWorkerSelectorLabels" -}}
app.kubernetes.io/name: {{ include "llama-cpp.name" . }}-rpc-worker
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Build the comma-separated --rpc flag value from the headless service DNS.
llama-server accepts a single --rpc host:port argument where host resolves
to multiple A records (all DaemonSet pod IPs via the headless service).
*/}}
{{- define "llama-cpp.rpcAddress" -}}
{{- printf "%s-rpc-worker:%d" (include "llama-cpp.fullname" .) (50052 | int) }}
{{- end }}
