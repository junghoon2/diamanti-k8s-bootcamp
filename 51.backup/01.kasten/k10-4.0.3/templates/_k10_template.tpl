{{/* Generate service spec */}}
{{- define "k10-default" }}
{{- $service := .k10_service }}
{{- with .main }}
{{- if $.stateful }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $service }}-pv-claim
  labels:
{{ include "helm.labels" . | indent 4 }}
    component: {{ $service }}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ default .Values.global.persistence.size (index .Values.global.persistence $service "size") }}
{{- if .Values.global.persistence.storageClass }}
  {{- if (eq "-" .Values.global.persistence.storageClass) }}
  storageClassName: ""
  {{- else }}
  storageClassName: "{{ .Values.global.persistence.storageClass }}"
  {{- end }}
{{- end }}
---
{{- end }}{{/* if $.stateful */}}
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $service }}-svc
  labels:
{{ include "helm.labels" . | indent 4 }}
    component: {{ $service }}
spec:
  replicas: {{ $.replicas }}
  strategy:
    type: Recreate
  selector:
    matchLabels:
{{ include "k10.common.matchLabels" . | indent 6 }}
      component: {{ $service }}
      run: {{ $service }}-svc
  template:
    metadata:
      annotations:
        checksum/config: {{ include (print .Template.BasePath "/k10-config.yaml") . | sha256sum }}
        checksum/secret: {{ include (print .Template.BasePath "/secrets.yaml") . | sha256sum }}
{{- if .Values.auth.ldap.restartPod }}
        rollme: {{ randAlphaNum 5 | quote }}
{{- end}}
      labels:
{{ include "helm.labels" . | indent 8 }}
        component: {{ $service }}
        run: {{ $service }}-svc
    spec:
{{- if eq $service "executor" }}
{{- if .Values.services.executor.hostNetwork }}
      hostNetwork: true
{{- end }}{{/* .Values.services.executor.hostNetwork */}}
{{- end }}{{/* eq $service "executor" */}}
{{- if eq $service "dashboardbff" }}
{{- if .Values.services.dashboardbff.hostNetwork }}
      hostNetwork: true
{{- end }}{{/* .Values.services.dashboardbff.hostNetwork */}}
{{- end }}{{/* eq $service "dashboardbff" */}}
      securityContext:
{{ toYaml .Values.services.securityContext | indent 8 }}
      serviceAccountName: {{ template "serviceAccountName" . }}
{{- if or .Values.secrets.dockerConfig .Values.secrets.dockerConfigPath }}
      imagePullSecrets:
        - name: k10-ecr
{{- end }}
{{- if and ( eq $service "auth" ) .Values.auth.ldap.enabled }}
      initContainers:
      - name: dex-init
        command:
        - /dex/dexconfigmerge
        args:
        - --config-path=/etc/dex/cfg/config.yaml
        - --secret-path=/var/run/secret/kasten.io/bind-secret/bindPW
        - --new-config-path=/dex-config/config.yaml
        - --secret-field=bindPW
        {{- dict "main" . "k10_service" $service | include "serviceImage" | indent 8 }}
        volumeMounts:
        - mountPath: /etc/dex/cfg
          name: config
        - mountPath: /dex-config
          name: dex-config
        - name: bind-secret
          mountPath: "/var/run/secret/kasten.io/bind-secret"
          readOnly: true
{{- else if $.stateful }}
      initContainers:
      - name: upgrade-init
        securityContext:
          runAsUser: 0
          allowPrivilegeEscalation: true
        {{- dict "main" . "k10_service" "upgrade" | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
          - name: MODEL_STORE_DIR
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: modelstoredirname
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: {{ .Values.global.persistence.mountPath | quote }}
{{- if eq $service "catalog" }}
      - name: schema-upgrade-check
        {{- dict "main" . "k10_service" $service | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        env:
{{- if .Values.clusterName }}
          - name: CLUSTER_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: clustername
{{- end }}
          - name: INIT_CONTAINER
            value: "true"
          - name: K10_RELEASE_NAME
            value: {{ .Release.Name }}
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: loglevel
          - name: MODEL_STORE_DIR
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: modelstoredirname
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: version
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: {{ .Values.global.persistence.mountPath | quote }}
{{- end }}{{/* eq $service "catalog" */}}
{{- end }}
      containers:
      - name: {{ $service }}-svc
        {{- dict "main" . "k10_service" $service | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.image.pullPolicy }}
{{- if eq $service "aggregatedapis" }}
        args:
        - "--secure-port={{ .Values.service.aggregatedApiPort }}"
        - "--cert-dir=/tmp/apiserver.local.config/certificates/"
{{- if .Values.useNamespacedAPI }}
        - "--k10-api-domain={{  template "apiDomain" . }}"
{{- end }}{{/* .Values.useNamespacedAPI */}}
{{- end }}{{/* eq $service "aggregatedapis" */}}
{{- $podName := (printf "%s-svc" $service) }}
{{- $containerName := (printf "%s-svc" $service) }}
{{- dict "main" . "k10_service_pod_name" $podName "k10_service_container_name" $containerName  | include "k10.resource.request" | indent 8}}
        ports:
{{- if eq $service "aggregatedapis" }}
        - containerPort: {{ .Values.service.aggregatedApiPort }}
{{- else }}
        - containerPort: {{ .Values.service.externalPort }}
{{- end }}
{{- if eq $service "logging" }}
        - containerPort: 24224
          protocol: TCP
        - containerPort: 24225
          protocol: TCP
{{- end }}
        livenessProbe:
{{- if eq $service "aggregatedapis" }}
          tcpSocket:
            port: {{ .Values.service.aggregatedApiPort }}
          timeoutSeconds: 5
{{- else }}
          httpGet:
            path: /v0/healthz
            port: {{ .Values.service.externalPort }}
          timeoutSeconds: 1
{{- end }}
          initialDelaySeconds: 300
{{- if ne $service "aggregatedapis" }}
        readinessProbe:
          httpGet:
            path: /v0/healthz
            port: {{ .Values.service.externalPort }}
          initialDelaySeconds: 3
{{- end }}
        env:
{{- if eq (include "check.googlecreds" .) "true" }}
          - name: GOOGLE_APPLICATION_CREDENTIALS
            value: "/var/run/secret/kasten.io/kasten-gke-sa.json"
{{- end }}
{{- if eq (include "check.ibmslcreds" .) "true" }}
          - name: IBM_SL_API_KEY
            valueFrom:
              secretKeyRef:
                name: ibmsl-secret
                key: ibm_sl_key
          - name: IBM_SL_API_USERNAME
            valueFrom:
              secretKeyRef:
                name: ibmsl-secret
                key: ibm_sl_username
{{- end }}
{{- if eq (include "check.azurecreds" .) "true" }}
          - name: AZURE_TENANT_ID
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_tenant_id
          - name: AZURE_CLIENT_ID
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_client_id
          - name: AZURE_CLIENT_SECRET
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_client_secret
{{- if .Values.secrets.azureResourceGroup }}
          - name: AZURE_RESOURCE_GROUP
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_resource_group
{{- end }}
{{- if .Values.secrets.azureSubscriptionID }}
          - name: AZURE_SUBSCRIPTION_ID
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_subscription_id
{{- end }}
{{- if .Values.secrets.azureResourceMgrEndpoint }}
          - name: AZURE_RESOURCE_MANAGER_ENDPOINT
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_resource_manager_endpoint
{{- end }}
{{- if .Values.secrets.azureADEndpoint }}
          - name: AZURE_AD_ENDPOINT
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_ad_endpoint
{{- end }}
{{- if .Values.secrets.azureADResourceID }}
          - name: AZURE_AD_RESOURCE
            valueFrom:
              secretKeyRef:
                name: azure-creds
                key: azure_ad_resource_id
{{- end }}
{{- end }}
{{- if eq (include "check.awscreds" .) "true" }}
          - name: AWS_ACCESS_KEY_ID
            valueFrom:
              secretKeyRef:
                name: aws-creds
                key: aws_access_key_id
          - name: AWS_SECRET_ACCESS_KEY
            valueFrom:
              secretKeyRef:
                name: aws-creds
                key: aws_secret_access_key
{{- if .Values.secrets.awsIamRole }}
          - name: K10_AWS_IAM_ROLE
            valueFrom:
              secretKeyRef:
                name: aws-creds
                key: role
{{- end }}
{{- end }}
{{- if eq (include "check.vspherecreds" .) "true" }}
          - name: VSPHERE_ENDPOINT
            valueFrom:
              secretKeyRef:
                name: vsphere-creds
                key: vsphere_endpoint
          - name: VSPHERE_USERNAME
            valueFrom:
              secretKeyRef:
                name: vsphere-creds
                key: vsphere_username
          - name: VSPHERE_PASSWORD
            valueFrom:
              secretKeyRef:
                name: vsphere-creds
                key: vsphere_password
{{- end }}
          - name: VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: version
{{- if .Values.clusterName }}
          - name: CLUSTER_NAME
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: clustername
{{- end }}
{{- if eq $service "config" }}
          - name: K10_STATEFUL
            value: "{{ .Values.global.persistence.enabled }}"
{{- end }}
          - name: MODEL_STORE_DIR
{{- if or (eq $service "state") (not .Values.global.persistence.enabled) }}
            value: "/tmp/k10store"
{{- else }}
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: modelstoredirname
{{- end }}
{{- if (eq $service "kanister") }}
          - name: DATA_MOVER_IMAGE
            value: {{ default .Chart.Version .Values.image.tag | print .Values.image.registry "/" .Values.image.repository "/datamover:"  }}
{{- end }}
          - name: LOG_LEVEL
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: loglevel
{{- if .Values.kanisterPodCustomLabels }}
          - name: KANISTER_POD_CUSTOM_LABELS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterPodCustomLabels
{{- end }}
{{- if .Values.kanisterPodCustomAnnotations }}
          - name: KANISTER_POD_CUSTOM_ANNOTATIONS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: kanisterPodCustomAnnotations
{{- end }}
          - name: POD_NAMESPACE
            valueFrom:
              fieldRef:
                fieldPath: metadata.namespace
          - name: CONCURRENT_SNAP_CONVERSIONS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: concurrentSnapConversions
          - name: CONCURRENT_WORKLOAD_SNAPSHOTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: concurrentWorkloadSnapshots
          - name: K10_DATA_STORE_PARALLEL_UPLOAD
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreParallelUpload
          - name: K10_DATA_STORE_GENERAL_CONTENT_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreGeneralContentCacheSizeMB
          - name: K10_DATA_STORE_GENERAL_METADATA_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreGeneralMetadataCacheSizeMB
          - name: K10_DATA_STORE_RESTORE_CONTENT_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreRestoreContentCacheSizeMB
          - name: K10_DATA_STORE_RESTORE_METADATA_CACHE_SIZE_MB
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: k10DataStoreRestoreMetadataCacheSizeMB
          - name: K10_LIMITER_GENERIC_VOLUME_SNAPSHOTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterGenericVolumeSnapshots
          - name: K10_LIMITER_GENERIC_VOLUME_COPIES
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterGenericVolumeCopies
          - name: K10_LIMITER_GENERIC_VOLUME_RESTORES
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterGenericVolumeRestores
          - name: K10_LIMITER_CSI_SNAPSHOTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterCsiSnapshots
          - name: K10_LIMITER_PROVIDER_SNAPSHOTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10LimiterProviderSnapshots
{{- if .Values.useNamespacedAPI }}
          - name: K10_API_DOMAIN
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: apiDomain
{{- end }}
{{- if .Values.jaeger.enabled }}
          - name: JAEGER_AGENT_HOST
            value: {{ .Values.jaeger.agentDNS }}
{{- end }}
{{- if .Values.auth.tokenAuth.enabled }}
          - name: TOKEN_AUTH
            valueFrom:
              secretKeyRef:
                name: k10-token-auth
                key: auth
{{- end }}
{{- if eq "true" (include "overwite.kanisterToolsImage" .) }}
          - name: KANISTER_TOOLS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: overwriteKanisterTools
{{- end }}
{{- if eq (include "check.cacertconfigmap" .) "true" }}
          - name: CACERT_CONFIGMAP_NAME
            value: {{ .Values.cacertconfigmap.name }}
{{- end }}
          - name: K10_RELEASE_NAME
            value: {{ .Release.Name }}
          - name: KANISTER_FUNCTION_VERSION
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: kanisterFunctionVersion
{{- if and (eq $service "config") (.Values.injectKanisterSidecar.enabled) }}
          - name: K10_MUTATING_WEBHOOK_ENABLED
            value: "true"
          - name: K10_MUTATING_WEBHOOK_TLS_CERT_DIR
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: K10MutatingWebhookTLSCertDir
          - name: K10_MUTATING_WEBHOOK_PORT
            value: {{ .Values.injectKanisterSidecar.webhookServer.port | quote }}
{{- end }}
{{- if or (eq $service "config") (eq $service "kanister") }}
{{- if .Values.genericVolumeSnapshot.resources.requests.memory }}
          - name: KANISTER_TOOLS_MEMORY_REQUESTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsMemoryRequests
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.requests.cpu }}
          - name: KANISTER_TOOLS_CPU_REQUESTS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsCPURequests
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.limits.memory }}
          - name: KANISTER_TOOLS_MEMORY_LIMITS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsMemoryLimits
{{- end }}
{{- if .Values.genericVolumeSnapshot.resources.limits.cpu }}
          - name: KANISTER_TOOLS_CPU_LIMITS
            valueFrom:
              configMapKeyRef:
                name: k10-config
                key: KanisterToolsCPULimits
{{- end }}
{{- end }}
{{- if and (or (eq $service "dashboardbff") (eq $service "config")) (.Values.prometheus.server.enabled) }}
          - name: K10_PROMETHEUS_HOST
            value: {{ include "k10.prometheus.service.name" . }}-exp
          - name: K10_PROMETHEUS_PORT
            value: {{ .Values.prometheus.server.service.servicePort | quote }}
          - name: K10_PROMETHEUS_BASE_URL
            value: {{ .Values.prometheus.server.baseURL }}
{{- end }}
{{- if or $.stateful (or (eq (include "check.googlecreds" .) "true") (eq $service "auth" "logging")) }}
        volumeMounts:
{{- else if  or (or (eq (include "basicauth.check" .) "true") (or .Values.auth.oidcAuth.enabled (eq (include "check.dexAuth" .) "true"))) .Values.features }}
        volumeMounts:
{{- else if and (eq $service "config") (.Values.injectKanisterSidecar.enabled) }}
        volumeMounts:
{{- else if eq (include "check.cacertconfigmap" .) "true" }}
        volumeMounts:
{{- end }}
{{- if $.stateful }}
        - name: {{ $service }}-persistent-storage
          mountPath: {{ .Values.global.persistence.mountPath | quote }}
{{- end }}
{{- if .Values.features }}
        - name: k10-features
          mountPath: "/mnt/k10-features"
{{- end }}
{{- if eq $service "logging" }}
        - name: logging-configmap-storage
          mountPath: "/mnt/conf"
{{- end }}
{{- if and (eq $service "config") (.Values.injectKanisterSidecar.enabled) }}
        - name: mutating-webhook-certs
          mountPath: /etc/ssl/certs/webhook
          readOnly: true
{{- end }}
{{- if eq (include "basicauth.check" .) "true" }}
        - name: k10-basic-auth
          mountPath: "/var/run/secret/kasten.io/k10-basic-auth"
          readOnly: true
{{- end }}
{{- if (or .Values.auth.oidcAuth.enabled (eq (include "check.dexAuth" .) "true")) }}
        - name: k10-oidc-auth
          mountPath: "/var/run/secret/kasten.io/k10-oidc-auth"
          readOnly: true
{{- end }}
{{- if eq (include "check.googlecreds" .) "true" }}
        - name: service-account
          mountPath: "/var/run/secret/kasten.io"
{{- end }}
{{- if eq (include "check.cacertconfigmap" .) "true" }}
        - name: {{ .Values.cacertconfigmap.name }}
          mountPath: "/etc/ssl/certs/custom-ca-bundle.pem"
          subPath: custom-ca-bundle.pem
{{- end }}
{{- if .Values.toolsImage.enabled }}
{{- if eq $service "executor" }}
      - name: tools
        {{- dict "main" . "k10_service" "cephtool" | include "serviceImage" | indent 8 }}
        imagePullPolicy: {{ .Values.toolsImage.pullPolicy }}
{{- $podName := (printf "%s-svc" $service) }}
{{- dict "main" . "k10_service_pod_name" $podName "k10_service_container_name" "tools"  | include "k10.resource.request" | indent 8}}
{{- end }}
{{- end }} {{/* .Values.toolsImage.enabled */}}
{{- if and (eq $service "catalog") $.stateful }}
      - name: kanister-sidecar
        image: {{ include "get.kanisterToolsImage" .}}
        imagePullPolicy: {{ .Values.kanisterToolsImage.pullPolicy }}
{{- $podName := (printf "%s-svc" $service) }}
{{- dict "main" . "k10_service_pod_name" $podName "k10_service_container_name" "kanister-sidecar"  | include "k10.resource.request" | indent 8}}
        volumeMounts:
        - name: {{ $service }}-persistent-storage
          mountPath: {{ .Values.global.persistence.mountPath | quote }}
{{- if eq (include "check.cacertconfigmap" .) "true" }}
        - name: {{ .Values.cacertconfigmap.name }}
          mountPath: "/etc/ssl/certs/custom-ca-bundle.pem"
          subPath: custom-ca-bundle.pem
{{- end }}
{{- end }} {{/* and (eq $service "catalog") $.stateful */}}
{{- if and ( eq $service "auth" ) ( or .Values.auth.dex.enabled (eq (include "check.dexAuth" .) "true")) }}
      - name: dex
        image: {{ include "k10.dexImage" . }}
{{- if .Values.auth.ldap.enabled }}
        command: ["/usr/local/bin/dex", "serve", "/dex-config/config.yaml"]
{{- else }}
        command: ["/usr/local/bin/dex", "serve", "/etc/dex/cfg/config.yaml"]
{{- end }}
        ports:
        - name: http
          containerPort: 8080
        volumeMounts:
{{- if .Values.auth.ldap.enabled }}
        - name: dex-config
          mountPath: /dex-config
        - name: k10-logos-dex
          mountPath: /web/themes/custom/
{{- else }}
        - name: config
          mountPath: /etc/dex/cfg
{{- end }}
{{- if eq (include "check.cacertconfigmap" .) "true" }}
        - name: {{ .Values.cacertconfigmap.name }}
          mountPath: "/etc/ssl/certs/custom-ca-bundle.pem"
          subPath: custom-ca-bundle.pem
{{- end }}
{{- end }} {{/* end of dex check */}}
{{- if or $.stateful (or (eq (include "check.googlecreds" .) "true") (eq $service "auth" "logging")) }}
      volumes:
{{- else if or (or (eq (include "basicauth.check" .) "true") (or .Values.auth.oidcAuth.enabled (eq (include "check.dexAuth" .) "true"))) .Values.features }}
      volumes:
{{- else if and (eq $service "config") (.Values.injectKanisterSidecar.enabled) }}
      volumes:
{{- else if eq (include "check.cacertconfigmap" .) "true" }}
      volumes:
{{- else if and ( eq $service "auth" ) ( or .Values.auth.dex.enabled (eq (include "check.dexAuth" .) "true")) }}
      volumes:
{{- end }}
{{- if .Values.features }}
      - name: k10-features
        configMap:
          name: k10-features
{{- end }}
{{- if eq (include "basicauth.check" .) "true" }}
      - name: k10-basic-auth
        secret:
          secretName: {{ default "k10-basic-auth" .Values.auth.basicAuth.secretName }}
{{- end }}
{{- if .Values.auth.oidcAuth.enabled }}
      - name: k10-oidc-auth
        secret:
          secretName: {{ default "k10-oidc-auth" .Values.auth.oidcAuth.secretName }}
{{- end }}
{{- if .Values.auth.openshift.enabled }}
      - name: k10-oidc-auth
        secret:
          secretName: {{ default "k10-oidc-auth" .Values.auth.openshift.secretName }}
{{- end }}
{{- if .Values.auth.ldap.enabled }}
      - name: k10-oidc-auth
        secret:
          secretName: {{ default "k10-oidc-auth" .Values.auth.ldap.secretName }}
      - name: k10-logos-dex
        configMap:
          name: k10-logos-dex
{{- end }}
{{- if $.stateful }}
      - name: {{ $service }}-persistent-storage
        persistentVolumeClaim:
          claimName: {{ $service }}-pv-claim
{{- end }}
{{- if eq (include "check.googlecreds" .) "true" }}
      - name: service-account
        secret:
          secretName: google-secret
{{- end }}
{{- if eq (include "check.cacertconfigmap" .) "true" }}
      - name: {{ .Values.cacertconfigmap.name }}
        configMap:
          name: {{ .Values.cacertconfigmap.name }}
{{- end }}
{{- if eq $service "logging" }}
      - name: logging-configmap-storage
        configMap:
          name: fluentbit-configmap
{{- end }}
{{- if and (eq $service "config") (.Values.injectKanisterSidecar.enabled) }}
      - name: mutating-webhook-certs
        secret:
          secretName: {{ include "k10.configAPIs" . }}-certs
{{- end }}
{{- if and ( eq $service "auth" ) (or .Values.auth.dex.enabled (eq (include "check.dexAuth" .) "true")) }}
      - name: config
        configMap:
          name: k10-dex
          items:
          - key: config.yaml
            path: config.yaml
{{- if .Values.auth.ldap.enabled }}
      - name: dex-config
        emptyDir: {}
      - name: bind-secret
        secret:
          secretName: {{ default "k10-dex" .Values.auth.ldap.bindPWSecretName }}
{{- end }}
{{- end }}
---
{{- end }}{{/* with .main */}}
{{- end }}{{/* define "k10-default" */}}
