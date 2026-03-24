{{/* Generate the main controller from the documented top-level values when the
user does not provide their own controller structure. */}}
{{- define "fooocus_extend.defaults.controller" -}}
{{- $controllers := default (dict) .Values.controllers -}}
{{- if not (hasKey $controllers "main") }}
controllers:
  main:
    type: deployment
    replicas: {{ .Values.fooocusExtend.replicas }}
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
            value: {{ .Values.fooocusExtend.timezone | quote }}
          - name: PUID
            value: {{ .Values.fooocusExtend.uid | quote }}
          - name: PGID
            value: {{ .Values.fooocusExtend.gid | quote }}
          - name: CMDARGS
            value: {{ .Values.fooocusExtend.cmdArgs | quote }}
          - name: DATADIR
            value: "/content/data"
          - name: config_path
            value: "/content/data/state/config/config.txt"
          - name: config_example_path
            value: "/content/data/state/config/config_modification_tutorial.txt"
          - name: path_checkpoints
            value: "/content/data/models/checkpoints/"
          - name: path_loras
            value: "/content/data/models/loras/"
          - name: path_embeddings
            value: "/content/data/models/embeddings/"
          - name: path_vae_approx
            value: "/content/data/models/vae_approx/"
          - name: path_upscale_models
            value: "/content/data/models/upscale_models/"
          - name: path_inpaint
            value: "/content/data/models/inpaint/"
          - name: path_controlnet
            value: "/content/data/models/controlnet/"
          - name: path_clip_vision
            value: "/content/data/models/clip_vision/"
          - name: path_fooocus_expansion
            value: "/content/data/models/prompt_expansion/fooocus_expansion/"
          - name: path_outputs
            value: "/content/app/outputs/"
        securityContext:
{{ toYaml (.Values.containerSecurityContext | default (dict)) | indent 10 }}
        ports:
          - name: web
            containerPort: {{ .Values.fooocusExtend.port }}
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

{{/* Default pod security context aligns writable mounted paths with the gid
while still allowing the container entrypoint to start as root and drop
privileges later. */}}
{{- define "fooocus_extend.defaults.podOptions" -}}
{{- if not .Values.defaultPodOptions }}
defaultPodOptions:
  securityContext:
{{ toYaml (.Values.podSecurityContext | default (dict)) | indent 4 }}
{{- end -}}
{{- end -}}
