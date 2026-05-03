{{/*
Expand the name of the chart.
*/}}
{{- define "observability-site.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "observability-site.fullname" -}}
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
{{- define "observability-site.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "observability-site.labels" -}}
helm.sh/chart: {{ include "observability-site.chart" . }}
{{ include "observability-site.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
environment: {{ .Values.environment }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "observability-site.selectorLabels" -}}
app.kubernetes.io/name: {{ include "observability-site.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app: {{ .Values.labels.app | quote }}
component: {{ .Values.labels.component | quote }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "observability-site.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "observability-site.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
