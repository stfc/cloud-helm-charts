{{/*
Expand the name of the chart.
*/}}
{{- define "docker-registry.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "docker-registry.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end }}
{{- end -}}
{{- end -}}

{{- define "docker-registry.envs" -}}
- name: REGISTRY_HTTP_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ template "docker-registry.fullname" . }}-secret
      key: haSharedSecret

{{- if eq .Values.storage "filesystem" }}
- name: REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY
  value: "/var/lib/registry"

{{- else if eq .Values.storage "s3" }}
- name: REGISTRY_STORAGE_S3_REGION
  value: {{ required ".Values.s3.region is required" .Values.s3.region }}
- name: REGISTRY_STORAGE_S3_BUCKET
  value: {{ required ".Values.s3.bucket is required" .Values.s3.bucket }}
- name: REGISTRY_STORAGE_S3_ACCESSKEY
  valueFrom:
    secretKeyRef:
      name: {{ if .Values.secrets.s3.secretRef }}{{ .Values.secrets.s3.secretRef }}{{ else }}{{ template "docker-registry.fullname" . }}-secret{{ end }}
      key: s3AccessKey
- name: REGISTRY_STORAGE_S3_SECRETKEY
  valueFrom:
    secretKeyRef:
      name: {{ if .Values.secrets.s3.secretRef }}{{ .Values.secrets.s3.secretRef }}{{ else }}{{ template "docker-registry.fullname" . }}-secret{{ end }}
      key: s3SecretKey
- name: REGISTRY_STORAGE_S3_REGIONENDPOINT
  value: {{ .Values.s3.regionEndpoint }}
- name: REGISTRY_STORAGE_S3_ROOTDIRECTORY
  value: {{ .Values.s3.rootdirectory | quote }}
- name: REGISTRY_STORAGE_S3_ENCRYPT
  value: {{ .Values.s3.encrypt | quote }}
- name: REGISTRY_STORAGE_S3_SECURE
  value: {{ .Values.s3.secure | quote }}
- name: REGISTRY_STORAGE_S3_SKIPVERIFY
  value: {{ .Values.s3.skipverify | quote }}
- name: REGISTRY_PROXY_REMOTEURL
  value: {{ required ".Values.proxy.remoteURL is required" .Values.proxy.remoteURL }}
- name: REGISTRY_PROXY_USERNAME
  valueFrom:
    secretKeyRef:
      name: {{ if .Values.secrets.secretRef }}{{ .Values.secrets.secretRef }}{{ else }}{{ template "docker-registry.fullname" . }}-secret{{ end }}
      key: proxyUsername
- name: REGISTRY_PROXY_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ if .Values.secrets.secretRef }}{{ .Values.secrets.secretRef }}{{ else }}{{ template "docker-registry.fullname" . }}-secret{{ end }}
      key: proxyPassword
{{- end -}}
{{- with .Values.extraEnvVars }}
{{ toYaml . }}
{{- end }}
{{- end -}}

{{- define "docker-registry.volumeMounts" -}}
- name: "{{ template "docker-registry.fullname" . }}-config"
  mountPath: /etc/docker/registry/

{{- if eq .Values.storage "filesystem" }}
- name: data
  mountPath: /var/lib/registry/
{{- end }}
{{- end -}}

{{- define "docker-registry.volumes" -}}
- name: {{ template "docker-registry.fullname" . }}-config
  configMap:
    name: {{ template "docker-registry.fullname" . }}-config

{{- if eq .Values.storage "filesystem" }}
- name: data
  {{- if .Values.persistence.enabled -}}
  persistentVolumeClaim:
    claimName: {{ if .Values.persistence.existingClaim }}{{ .Values.persistence.existingClaim }}{{- else }}{{ template "docker-registry.fullname" . }}{{- end }}
  {{- else }}
  emptyDir: {}
  {{- end -}}
{{- end }}
{{- end -}}