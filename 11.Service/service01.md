# Kubernetes Service
- ### Kubernetes 환경에서 서로 다른 POD 간 통신은 Service 사용
- ### POD는 항상 생성되고 사라질 수 있으므로 유동적으로 변할 수 있는 POD IP가 아닌 Domain Name 사용
- ### POD IP는 Service의 Domain Name IP로 등록 

## 실습을 위한 Deploy, POD 생성
소스 코드
- [NGINX Deploy 생성](../02.Deploy/nginxhello-deploy.yml)
- [CentOS7 POD 생성](../01.Pod/centos7-pod.yml)
- [CentOS7 POD 생성 - Namespace test](../01.Pod/centos7-ns-pod.yml)

```
kc apply -f [YAML]

spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod
NAME                                READY   STATUS    RESTARTS   AGE
centos7                             1/1     Running   0          4h19m
nginx-deployment-7b5544b744-mdt8j   1/1     Running   0          130m

spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -n test
NAME             READY   STATUS    RESTARTS   AGE
centos7          1/1     Running   0          157m
```

## Service 생성
소스 코드
- [NGINX POD 용 Service 생성](../11.Service/headless-svc.yml)

DIAMANTI에서는 Service Type으로 ClusterIP, ClusterIP 옵션은 None으로 사용([Headless Service 참조](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services))

SR-IOV를 사용하여 개별 POD 별 가상 NIC 직접 할당하므로 Service Type Headless 사용(NodePort Bridge, NAT 불필요)

```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get svc
NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
kubernetes   ClusterIP   10.0.0.1     <none>        443/TCP   24d
web-svc      ClusterIP   None         <none>        80/TCP    161m

spkr@erdia22:~/02.k8s_code/04.Deploy$ kc describe svc web-svc
Name:              web-svc
Namespace:         default
Labels:            <none>
Annotations:       kubectl.kubernetes.io/last-applied-configuration:
                     {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"web-svc","namespace":"default"},"spec":{"clusterIP":"None","ports...
Selector:          app=web
Type:              ClusterIP
IP:                None
Port:              tcp  80/TCP
TargetPort:        80/TCP
Endpoints:         10.10.100.37:80  # NGINX POD IP 할당 
Session Affinity:  None
Events:            <none>

spkr@erdia22:~/02.k8s_code/01.POD$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
centos7                             1/1     Running   0          4h52m   10.10.100.27   dia02   <none>           <none>
nginx-deployment-7b5544b744-mdt8j   1/1     Running   0          164m    10.10.100.37   dia02   <none>           <none>
```

## CentOS POD - Nginx POD 간 통신은 Service 이용

### 같은 namespace 환경에서 Service 연결 확인
서비스 이름(web-svc)으로 Ping, curl 가능 (hostname 등으로는 안 됨) 
IP 통신도 가능

```
[root@centos7 /]# ping web-svc
PING web-svc.default.svc.cluster.local (10.10.100.37) 56(84) bytes of data.
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=1 ttl=64 time=0.168 ms
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=2 ttl=64 time=0.149 ms
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=3 ttl=64 time=0.119 ms
^C
--- web-svc.default.svc.cluster.local ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.119/0.145/0.168/0.022 ms

[root@centos7 /]# curl -I web-svc
HTTP/1.1 200 OK
Server: nginx/1.13.8
Date: Mon, 15 Jun 2020 07:01:32 GMT
Content-Type: text/html
Connection: keep-alive
Expires: Mon, 15 Jun 2020 07:01:31 GMT
Cache-Control: no-cache

[root@centos7 /]# ping nginx-deployment-7b5544b744-mdt8j
ping: nginx-deployment-7b5544b744-mdt8j: Name or service not known

[root@centos7 /]# ping 10.10.100.37
PING 10.10.100.37 (10.10.100.37) 56(84) bytes of data.
64 bytes from 10.10.100.37: icmp_seq=1 ttl=64 time=0.184 ms

```

### 서로 다른 Namespace(default vs test)에서 Service를 이용한 통신 확인 
서비스 이름 + Namespace 이름을 추가해야 Service 연결 가능

Test Namespace으로 POD 실행(exec)
```
spkr@erdia22:~/02.k8s_code/01.POD$ kc exec -it -n test  centos7-test -- bash
[root@centos7-test /]# ping web-svc
ping: web-svc: Name or service not known

[root@centos7-test /]# ping web-svc.default
PING web-svc.default.svc.cluster.local (10.10.100.37) 56(84) bytes of data.
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=1 ttl=64 time=0.282 ms
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=2 ttl=64 time=0.156 ms
^C
--- web-svc.default.svc.cluster.local ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 0.156/0.219/0.282/0.063 ms
```

Full Name은 {서비스 이름}.{Namespace}.{svc}.{Cluster Domain} 사용
```
[root@centos7-test /]# ping web-svc.default.svc.cluster.local
PING web-svc.default.svc.cluster.local (10.10.100.37) 56(84) bytes of data.
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=1 ttl=64 time=0.166 ms
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=2 ttl=64 time=0.163 ms
^C
--- web-svc.default.svc.cluster.local ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 0.163/0.164/0.166/0.012 ms
```

### 자동 Service Descovery 
서비스가 연결하는 POD 숫자를 기존 1개에서 3개로 증가하면 Service에서 자동 인식
(자동으로 증가된 POD만큼 Load Balancing)

POD 증가
```
spkr@erdia22:/mnt/c/Users/erdia$ kc scale deployment nginx-deployment --replicas=3
deployment.extensions/nginx-deployment scaled

spkr@erdia22:/mnt/c/Users/erdia$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
centos7                             1/1     Running   0          4h42m   10.10.100.27   dia02   <none>           <none>
nginx-deployment-7b5544b744-hdmwj   1/1     Running   0          5s      10.10.100.19   dia03   <none>           <none>
nginx-deployment-7b5544b744-mdt8j   1/1     Running   0          153m    10.10.100.37   dia02   <none>           <none>
nginx-deployment-7b5544b744-msgrr   1/1     Running   0          5s      10.10.100.30   dia01   <none>           <none>
```

POD 간 연결 3개의 POD로 자동으로 Load balancing
```
[root@centos7-test /]# ping web-svc.default
PING web-svc.default.svc.cluster.local (10.10.100.30) 56(84) bytes of data.
64 bytes from 10-10-100-30.web-svc.default.svc.cluster.local (10.10.100.30): icmp_seq=1 ttl=64 time=0.139 ms
(...)
[root@centos7-test /]# ping web-svc.default
PING web-svc.default.svc.cluster.local (10.10.100.37) 56(84) bytes of data.
64 bytes from 10-10-100-37.web-svc.default.svc.cluster.local (10.10.100.37): icmp_seq=1 ttl=64 time=0.145 ms
(...)
[root@centos7-test /]# ping web-svc.default
PING web-svc.default.svc.cluster.local (10.10.100.19) 56(84) bytes of data.
64 bytes from 10-10-100-19.web-svc.default.svc.cluster.local (10.10.100.19): icmp_seq=1 ttl=64 time=0.343 ms
(...)
```
향후 Ingress 등 LoadBalancer 설정 시 부하 증가 등에 따라 POD 개수 증가 시 자동으로 부하 분산됨 

### POD DNS Server 구성 
kubelet 시스템 서비스 설정 시 DNS 서버(--cluster-dns=10.0.0.10) 설정 
```
[diamanti@dia01 ~]$ ps aux|grep kubelet|grep dns
root      23952  5.4  0.0 5297876 128600 ?      Ssl  May22 1902:19 /usr/bin/kubelet --kubeconfig=/etc/kubernetes/kubeconfig --logtostderr=true --stderrthreshold=0 --v=2 --address=192.168.200.101 --authorization-mode=Webhook --read-only-port=0 --streaming-connection-idle-timeout=5m --make-iptables-util-chains=true --event-qps=0 --rotate-certificates=true --tls-cert-file=/etc/diamanti/certs/node/server.crt --tls-private-key-file=/etc/diamanti/certs/node/server.key --client-ca-file=/etc/diamanti/certs/node/ca.crt --address=192.168.200.101 --feature-gates=RotateKubeletServerCertificate=true,VolumeSnapshotDataSource=true --housekeeping-interval=10s --max-pods=110 --fail-swap-on=false --cluster-dns=10.0.0.10 --network-plugin=cni --cluster_domain=cluster.local --cgroup-driver=systemd --enable-controller-attach-detach=false
```
각 POD는 kubernetes 설정에 이용한 DNS Server(Core-DNS 등) DNS Server가 자동 할당됨 
```
spkr@erdia22:~/02.k8s_code/01.POD$ kc exec -it centos7 -- bash
[root@centos7 /]# cat /etc/resolv.conf
nameserver 10.0.0.10
search default.svc.cluster.local svc.cluster.local cluster.local
options ndots:5
```
