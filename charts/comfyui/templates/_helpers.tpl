{{- define "comfyui.sentinelSecretName" -}}
{{- if .Values.sentinel.existingSecret -}}
{{- .Values.sentinel.existingSecret -}}
{{- else -}}
{{- default (printf "%s-sentinel" (include "bjw-s.common.lib.chart.names.fullname" .)) .Values.sentinel.secretName -}}
{{- end -}}
{{- end -}}
