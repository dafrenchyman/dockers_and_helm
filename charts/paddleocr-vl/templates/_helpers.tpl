{{/*
Create the release-scoped base name used by bjw-s common after common.yaml sets global.nameOverride to the release name.
*/}}
{{- define "paddleocr_vl.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else if .Values.global.nameOverride -}}
{{- .Values.global.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "paddleocr_vl.serviceName.api" -}}
{{- printf "%s-api" (include "paddleocr_vl.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "paddleocr_vl.serviceName.pipeline" -}}
{{- printf "%s-pipeline" (include "paddleocr_vl.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "paddleocr_vl.serviceName.vlm" -}}
{{- printf "%s-vlm" (include "paddleocr_vl.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "paddleocr_vl.vlmBackendConfigEnabled" -}}
{{- $enabled := false -}}
{{- if .Values.vlm.sleepMode.enabled -}}
{{- $enabled = true -}}
{{- end -}}
{{- range $key, $value := .Values.vlm.backendConfig -}}
{{- if ne $value nil -}}
{{- $enabled = true -}}
{{- end -}}
{{- end -}}
{{- if $enabled }}true{{ end -}}
{{- end -}}
