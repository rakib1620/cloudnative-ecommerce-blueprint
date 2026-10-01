{{- define "ecommerce-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "ecommerce-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "ecommerce-service.labels" -}}
helm.sh/chart: {{ include "ecommerce-service.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "ecommerce-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.environment | default "dev" | quote }}
{{- end }}

{{- define "ecommerce-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ecommerce-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
