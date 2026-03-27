{{/* Generate the main controller from the documented top-level values when the
user does not provide their own controller structure. */}}
{{- define "ace_step_1_5.defaults.controller" -}}
{{- $controllers := default (dict) .Values.controllers -}}
{{- if not (hasKey $controllers "main") }}
controllers:
  main:
    type: deployment
    replicas: {{ .Values.aceStep.replicas }}
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
            value: {{ .Values.aceStep.timezone | quote }}
          - name: PUID
            value: {{ .Values.aceStep.uid | quote }}
          - name: PGID
            value: {{ .Values.aceStep.gid | quote }}
          - name: PORT
            value: {{ .Values.aceStep.port | quote }}
          - name: SERVER_NAME
            value: {{ .Values.aceStep.host | quote }}
          - name: LANGUAGE
            value: {{ .Values.aceStep.language | quote }}
          - name: ACESTEP_CONFIG_PATH
            value: {{ .Values.aceStep.configPath | quote }}
          - name: ACESTEP_LM_MODEL_PATH
            value: {{ .Values.aceStep.lmModelPath | quote }}
          - name: ACESTEP_DEVICE
            value: {{ .Values.aceStep.device | quote }}
          - name: ACESTEP_LM_BACKEND
            value: {{ .Values.aceStep.lmBackend | quote }}
          - name: ACESTEP_INIT_LLM
            value: {{ .Values.aceStep.initLlm | quote }}
          - name: ACESTEP_DOWNLOAD_SOURCE
            value: {{ .Values.aceStep.downloadSource | quote }}
          - name: ACESTEP_NO_INIT
            value: {{ ternary "true" "false" (.Values.aceStep.noInit | default true) | quote }}
{{- if .Values.aceStep.extraArgs }}
          - name: ACESTEP_EXTRA_ARGS
            value: {{ .Values.aceStep.extraArgs | quote }}
{{- end }}
          - name: MODELS_DIR
            value: "/opt/ace-step/data/models"
          - name: INPUTS_DIR
            value: "/opt/ace-step/data/inputs"
          - name: OUTPUTS_DIR
            value: "/opt/ace-step/data/outputs"
          - name: RUNTIME_STATE_DIR
            value: "/opt/ace-step/data/state"
        securityContext:
{{ toYaml (.Values.containerSecurityContext | default (dict)) | indent 10 }}
        ports:
          - name: web
            containerPort: {{ .Values.aceStep.port }}
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
              initialDelaySeconds: 30
              periodSeconds: 15
              timeoutSeconds: 10
              failureThreshold: 60
          readiness:
            enabled: false
            custom: true
            spec:
              httpGet:
                path: /
                port: web
              initialDelaySeconds: 120
              periodSeconds: 30
              timeoutSeconds: 10
              failureThreshold: 20
          liveness:
            enabled: false
            custom: true
            spec:
              httpGet:
                path: /
                port: web
              initialDelaySeconds: 300
              periodSeconds: 60
              timeoutSeconds: 10
              failureThreshold: 10
{{- end -}}
{{- end -}}

{{/* Default pod security context aligns writable mounted paths with the gid
while still allowing the container entrypoint to start as root and drop
privileges later. */}}
{{- define "ace_step_1_5.defaults.podOptions" -}}
{{- if not .Values.defaultPodOptions }}
defaultPodOptions:
  securityContext:
{{ toYaml (.Values.podSecurityContext | default (dict)) | indent 4 }}
{{- end -}}
{{- end -}}
