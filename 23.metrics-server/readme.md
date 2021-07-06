github code 기준으로 설치

수정된 component 파일로 설치 할 것
: TLS 설정 관련 수정
  - --kubelet-insecure-tls
: 1.21 버전에서 바로 되었음 

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

download https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

[spkr@erdia22 37.metrics-server (ubuns:demo)]$ ka components.yaml 
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created

Configuration
Depending on your cluster setup, you may also need to change flags passed to the Metrics Server container. Most useful flags:

--kubelet-preferred-address-types - The priority of node address types used when determining an address for connecting to a particular node (default [Hostname,InternalDNS,InternalIP,ExternalDNS,ExternalIP])
--kubelet-insecure-tls - Do not verify the CA of serving certificates presented by Kubelets. For testing purposes only.
--requestheader-client-ca-file - Specify a root certificate bundle for verifying client certificates on incoming requests.
