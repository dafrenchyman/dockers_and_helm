{{- define "paddleocr_vl.cacheEnv" -}}
- name: PADDLE_PDX_CACHE_HOME
  value: "/cache/paddlex"
- name: PADDLE_PDX_MODEL_SOURCE
  value: {{ .Values.paddleocr.modelSource | quote }}
- name: PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK
  value: {{ ternary "True" "False" .Values.paddleocr.disableModelSourceCheck | quote }}
- name: HF_HOME
  value: "/cache/huggingface"
- name: HF_HUB_CACHE
  value: "/cache/huggingface/hub"
- name: HUGGINGFACE_HUB_CACHE
  value: "/cache/huggingface/hub"
- name: MODELSCOPE_CACHE
  value: "/cache/modelscope"
- name: VLLM_CACHE_ROOT
  value: "/cache/vllm"
- name: VLLM_ASSETS_CACHE
  value: "/cache/vllm/assets"
- name: VLLM_MEDIA_CACHE
  value: "/cache/vllm/media"
- name: XDG_CACHE_HOME
  value: "/cache/xdg"
{{- end -}}

{{- define "paddleocr_vl.gpuEnv" -}}
- name: HPS_DEVICE_ID
  value: {{ .Values.gpu.deviceId | quote }}
- name: NVIDIA_VISIBLE_DEVICES
  value: {{ .Values.gpu.nvidiaVisibleDevices | quote }}
- name: NVIDIA_DRIVER_CAPABILITIES
  value: {{ .Values.gpu.driverCapabilities | quote }}
- name: TRITON_LIBCUDA_PATH
  value: {{ .Values.gpu.tritonLibcudaPath | quote }}
{{- end -}}

{{- define "paddleocr_vl.runtimeStateEnv" -}}
{{- if (index .Values.persistence "runtime-state").enabled }}
- name: TMPDIR
  value: "/state/tmp"
{{- end }}
{{- end -}}

{{- define "paddleocr_vl.defaults.controllers" -}}
{{- $controllers := default (dict) .Values.controllers -}}
controllers:
{{- if not (hasKey $controllers "api") }}
  api:
    type: deployment
    replicas: {{ .Values.paddleocr.replicas.api }}
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
          repository: {{ .Values.image.api.repository }}
          tag: {{ .Values.image.api.tag }}
          pullPolicy: {{ .Values.image.api.pullPolicy }}
        env:
          - name: HPS_TRITON_URL
            value: {{ printf "%s:8001" (include "paddleocr_vl.serviceName.pipeline" .) | quote }}
          - name: HPS_VLM_URL
            value: {{ printf "http://%s:8080" (include "paddleocr_vl.serviceName.vlm" .) | quote }}
          - name: HPS_MAX_CONCURRENT_INFERENCE_REQUESTS
            value: {{ .Values.serving.maxConcurrentInferenceRequests | quote }}
          - name: HPS_MAX_CONCURRENT_NON_INFERENCE_REQUESTS
            value: {{ .Values.serving.maxConcurrentNonInferenceRequests | quote }}
          - name: HPS_INFERENCE_TIMEOUT
            value: {{ .Values.serving.inferenceTimeoutSeconds | quote }}
          - name: HPS_HEALTH_CHECK_TIMEOUT
            value: {{ .Values.serving.healthCheckTimeoutSeconds | quote }}
          - name: HPS_LOG_LEVEL
            value: {{ .Values.serving.logLevel | quote }}
          - name: HPS_FILTER_HEALTH_ACCESS_LOG
            value: {{ ternary "true" "false" .Values.serving.filterHealthAccessLog | quote }}
          - name: HPS_UVICORN_WORKERS
            value: {{ .Values.serving.uvicornWorkers | quote }}
{{ include "paddleocr_vl.runtimeStateEnv" . | indent 10 }}
        securityContext:
{{ toYaml (.Values.containerSecurityContext | default (dict)) | indent 10 }}
        ports:
          - name: http
            containerPort: 8080
            protocol: TCP
        resources:
{{ toYaml .Values.resources.api | indent 10 }}
        probes:
          startup:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 5
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 30
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health/ready
                port: http
              initialDelaySeconds: 5
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 12
          liveness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 30
              periodSeconds: 30
              timeoutSeconds: 5
              failureThreshold: 5
{{- end }}
{{- if not (hasKey $controllers "pipeline") }}
  pipeline:
    type: deployment
    replicas: {{ .Values.paddleocr.replicas.pipeline }}
    strategy: Recreate
    pod:
{{- if .Values.runtimeClassName }}
      runtimeClassName: {{ .Values.runtimeClassName | quote }}
{{- end }}
      nodeSelector:
{{ toYaml (.Values.nodeSelector | default (dict)) | indent 8 }}
      tolerations:
{{ toYaml (.Values.tolerations | default (list)) | indent 8 }}
      affinity:
{{ toYaml (.Values.affinity | default (dict)) | indent 8 }}
    containers:
      app:
        image:
          repository: {{ .Values.image.pipeline.repository }}
          tag: {{ .Values.image.pipeline.tag }}
          pullPolicy: {{ .Values.image.pipeline.pullPolicy }}
        env:
          - name: HPS_VLM_URL
            value: {{ printf "http://%s:8080" (include "paddleocr_vl.serviceName.vlm" .) | quote }}
          - name: HPS_DEVICE_TYPE
            value: "gpu"
{{ include "paddleocr_vl.gpuEnv" . | indent 10 }}
{{ include "paddleocr_vl.cacheEnv" . | indent 10 }}
{{ include "paddleocr_vl.runtimeStateEnv" . | indent 10 }}
        securityContext:
{{ toYaml (.Values.containerSecurityContext | default (dict)) | indent 10 }}
        ports:
          - name: http
            containerPort: 8000
            protocol: TCP
          - name: grpc
            containerPort: 8001
            protocol: TCP
        resources:
{{ toYaml .Values.resources.pipeline | indent 10 }}
        probes:
          startup:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /v2/health/ready
                port: http
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 60
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /v2/health/ready
                port: http
              initialDelaySeconds: 5
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 12
          liveness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /v2/health/ready
                port: http
              initialDelaySeconds: 60
              periodSeconds: 30
              timeoutSeconds: 5
              failureThreshold: 6
{{- end }}
{{- if not (hasKey $controllers "vlm") }}
  vlm:
    type: deployment
    replicas: {{ .Values.paddleocr.replicas.vlm }}
    strategy: Recreate
    pod:
{{- if .Values.runtimeClassName }}
      runtimeClassName: {{ .Values.runtimeClassName | quote }}
{{- end }}
      nodeSelector:
{{ toYaml (.Values.nodeSelector | default (dict)) | indent 8 }}
      tolerations:
{{ toYaml (.Values.tolerations | default (list)) | indent 8 }}
      affinity:
{{ toYaml (.Values.affinity | default (dict)) | indent 8 }}
    containers:
      app:
        image:
          repository: {{ .Values.image.vlm.repository }}
          tag: {{ .Values.image.vlm.tag }}
          pullPolicy: {{ .Values.image.vlm.pullPolicy }}
        command:
          - paddleocr
          - genai_server
          - --model_name
          - {{ .Values.paddleocr.vlmName | quote }}
          - --host
          - "0.0.0.0"
          - --port
          - "8080"
          - --backend
          - {{ .Values.vlm.backend | quote }}
{{- if .Values.vlm.modelDir }}
          - --model_dir
          - {{ .Values.vlm.modelDir | quote }}
{{- end }}
{{- if include "paddleocr_vl.vlmBackendConfigEnabled" . }}
          - --backend_config
          - /config/vllm_config.yaml
{{- end }}
{{- range .Values.vlm.extraArgs }}
          - {{ . | quote }}
{{- end }}
        env:
{{ include "paddleocr_vl.gpuEnv" . | indent 10 }}
{{ include "paddleocr_vl.cacheEnv" . | indent 10 }}
{{- if and .Values.vlm.sleepMode.enabled .Values.vlm.sleepMode.devMode }}
          - name: VLLM_SERVER_DEV_MODE
            value: "1"
{{- end }}
{{ include "paddleocr_vl.runtimeStateEnv" . | indent 10 }}
        securityContext:
{{ toYaml (.Values.containerSecurityContext | default (dict)) | indent 10 }}
        ports:
          - name: http
            containerPort: 8080
            protocol: TCP
        resources:
{{ toYaml .Values.resources.vlm | indent 10 }}
        probes:
          startup:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 90
          readiness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 10
              periodSeconds: 10
              timeoutSeconds: 5
              failureThreshold: 12
          liveness:
            enabled: true
            custom: true
            spec:
              httpGet:
                path: /health
                port: http
              initialDelaySeconds: 120
              periodSeconds: 30
              timeoutSeconds: 5
              failureThreshold: 6
{{- end }}
{{- end -}}

{{- define "paddleocr_vl.defaults.podOptions" -}}
{{- if not .Values.defaultPodOptions }}
defaultPodOptions:
  securityContext:
{{ toYaml (.Values.podSecurityContext | default (dict)) | indent 4 }}
{{- end -}}
{{- end -}}
