# Kubernetes Service
### Kubernetes 환경에서 서로 다른 POD 간 통신은 Service 사용
### POD는 항상 생성되고 사라질 수 있으므로 유동적으로 변할 수 있는 POD의 IP가 아닌 Domain 기준으로 상호 간 통신
### POD의 IP는 Service의 Domain Name으로 등록됨 

## 실습을 위한 Deploy POD 생성
- [NGINX Deploy 생성](../02.Deploy/nginxhello-deploy.yml)
- [CentOS7 POD 생성](../01.Pod/centos7-pod.yml)
- [CentOS7 POD - Test Namespace 생성](../01.Pod/centos7-ns-pod.yml)

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
- [NGINX POD 용 Service 생성](../11.Service/headless-svc.yml)
DIAMANTI에서는 Service Type으로 ClusterIP, ClusterIP 옵션은 None으로 지정([Headless Service](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
SR-IOV를 사용하여 개별 POD 별 가상 NIC 직접 할당

```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc exec -it centos7 -- bash
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
Endpoints:         10.10.100.37:80
Session Affinity:  None
Events:            <none>
```

## CentOS POD - Nginx POD 간 통신은 Service 이용
### Ping, CURL 통한 연결 확인

### 같은 namespace 환경에서 Service 연결 확인
서비스 이름(web-svc)으로 Ping, CURL 가능 (hostname 등으로는 안 됨) IP 통신도 가능

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
서비스 이름 + Namespace 이름을 추가해야 Service 연결
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

Full Name은 <서비스 이름>.<Namespace>.<svc>.<Cluster Domain> 으로 연결
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
서비스가 연결하는 POD의 숫자를 기존 1개에서 3개로 증가 시 자동으로 증가된 POD로 Load Balancing 됨

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

POD 간 연결도 3개의 POD로 자동으로 Load balancing
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
향후 Ingress 등 Proxy 설정 시 부하 증가에 따라 POD 개수 증가 시 자동으로 부하 분산 
