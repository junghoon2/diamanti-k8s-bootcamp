github code 기준으로 설치

0.6 버전으로 이 후 바로 설치 가능 
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

[spkr@erdia22 dynamic-provisioning (kube@k10-kube.ap-northeast-2.eksctl.io:emojivoto)]$ kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
serviceaccount/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created
service/metrics-server created
deployment.apps/metrics-server created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created

[spkr@erdia22 dynamic-provisioning (kube@k10-kube.ap-northeast-2.eksctl.io:emojivoto)]$ kgp -n kube-system
NAME                                  READY   STATUS    RESTARTS   AGE   IP               NODE                                               NOMINATED NODE   READINESS GATES
aws-node-75r5g                        1/1     Running   0          25h   192.168.24.10    ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
coredns-78fb67b999-7wj9q              1/1     Running   0          25h   192.168.8.34     ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
coredns-78fb67b999-k2pmk              1/1     Running   0          25h   192.168.16.29    ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
ebs-csi-controller-79db79b56f-246mj   6/6     Running   0          24h   192.168.18.233   ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
ebs-csi-controller-79db79b56f-ghzrz   6/6     Running   0          24h   192.168.30.164   ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
ebs-csi-node-w5kpx                    3/3     Running   0          24h   192.168.19.196   ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
ebs-snapshot-controller-0             1/1     Running   0          24h   192.168.8.163    ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
kube-proxy-hsskl                      1/1     Running   0          25h   192.168.24.10    ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>
metrics-server-9f459d97b-wvcwc        1/1     Running   0          60s   192.168.2.158    ip-192-168-24-10.ap-northeast-2.compute.internal   <none>           <none>

### 이전 버전 
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
