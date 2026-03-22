{{/* Generate the main controller from the documented top-level values when the
user does not provide their own controller structure. */}}
{{- define "comfyui.defaults.controller" -}}
{{- $controllers := default (dict) .Values.controllers -}}
{{- if not (hasKey $controllers "main") }}
controllers:
  main:
    type: deployment
    replicas: {{ .Values.comfyui.replicas }}
    strategy: Recreate
    pod:
      nodeSelector:
{{ toYaml (.Values.nodeSelector | default (dict)) | indent 8 }}
      tolerations:
{{ toYaml (.Values.tolerations | default (list)) | indent 8 }}
      affinity:
{{ toYaml (.Values.affinity | default (dict)) | indent 8 }}
    containers:
      app:
        image:
          repository: {{ .Values.image.repository }}
          tag: {{ .Values.image.tag }}
          pullPolicy: {{ .Values.image.pullPolicy }}
        env:
          - name: TZ
            value: {{ .Values.comfyui.timezone | quote }}
          - name: PUID
            value: {{ .Values.comfyui.uid | quote }}
          - name: PGID
            value: {{ .Values.comfyui.gid | quote }}
          - name: COMFYUI_HOST
            value: {{ .Values.comfyui.host | quote }}
          - name: COMFYUI_PORT
            value: {{ .Values.comfyui.port | quote }}
          - name: SENTINEL_MANAGER_ADMIN_ONLY
            value: {{ ternary "true" "false" (.Values.sentinel.managerAdminOnly | default true) | quote }}
          - name: SENTINEL_SEPARATE_USERS
            value: {{ ternary "true" "false" (.Values.sentinel.separateUsers | default true) | quote }}
          - name: SECRET_KEY
            valueFrom:
              secretKeyRef:
                name: {{ include "comfyui.sentinelSecretName" . }}
                key: {{ .Values.sentinel.secretKeyKey | quote }}
{{- if .Values.comfyui.extraArgs }}
          - name: COMFYUI_EXTRA_ARGS
            value: {{ .Values.comfyui.extraArgs | quote }}
{{- end }}
        ports:
          - name: web
            containerPort: {{ .Values.comfyui.port }}
            protocol: TCP
        resources:
{{ toYaml .Values.resources | indent 10 }}
        probes:
          startup:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /
                port: web
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 30
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /
                port: web
              initialDelaySeconds: 20
              periodSeconds: 15
              timeoutSeconds: 5
              failureThreshold: 6
          liveness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /
                port: web
              initialDelaySeconds: 60
              periodSeconds: 30
              timeoutSeconds: 5
              failureThreshold: 5
{{- end -}}
{{- end -}}

{{/* Default fsGroup aligns writable mounted paths with comfyui.gid while still
allowing the container entrypoint to start as root and drop privileges later. */}}
{{- define "comfyui.defaults.podOptions" -}}
{{- if not .Values.defaultPodOptions }}
defaultPodOptions:
  securityContext:
    fsGroup: {{ .Values.comfyui.gid }}
    fsGroupChangePolicy: OnRootMismatch
{{- end -}}
{{- end -}}
