# POD 로그 확인(log)
- ### POD에서 생성되는 로그 정보는 kubectl log {POD Name} 명령어로 확인 가능
- ### 장애 등의 상황에서 POD 로그 확인 용도로 사용

소스 코드 : [event-simulator-pod](02.LogDescribe/event-simulator-pod.yml)

```
kc apply -f event-simulator-pod.yml

spkr@erdia22:~/02.k8s_code/01.POD$ kc logs event-simulator-pod
[2020-06-16 00:23:37,716] INFO in event-simulator: USER1 is viewing page2
[2020-06-16 00:23:38,718] INFO in event-simulator: USER3 is viewing page3
[2020-06-16 00:23:39,719] INFO in event-simulator: USER1 is viewing page2
[2020-06-16 00:23:40,721] INFO in event-simulator: USER1 logged in
(...)
```
-f(follow) 옵션 사용 시, 로그 메시지 계속 모니터링 가능
```
spkr@erdia22:~/02.k8s_code/01.POD$ kc logs event-simulator-pod -f
spkr@erdia22:~/02.k8s_code/01.POD$ kc logs event-simulator-pod
[2020-06-16 00:23:37,716] INFO in event-simulator: USER1 is viewing page2
[2020-06-16 00:23:38,718] INFO in event-simulator: USER3 is viewing page3
[2020-06-16 00:23:39,719] INFO in event-simulator: USER1 is viewing page2
[2020-06-16 00:23:40,721] INFO in event-simulator: USER1 logged in
```

# POD 등 Object 상세 정보 확인(describe)
- ### POD 상태, 이미지 버전 정보 등 Object 상세 정보 확인 용도
- ### kubectl describe pod {POD Name} 

```
spkr@erdia22:~/02.k8s_code/01.POD$ kc get pod
NAME                                READY   STATUS    RESTARTS   AGE
centos7                             1/1     Running   0          22h
event-simulator-pod                 1/1     Running   0          15m
nginx-deployment-7b5544b744-mdt8j   1/1     Running   0          20h

spkr@erdia22:~/02.k8s_code/01.POD$ kc describe pod event-simulator-pod
Name:         event-simulator-pod
Namespace:    default
Priority:     0
Node:         dia02/192.168.200.102
Start Time:   Tue, 16 Jun 2020 09:23:26 +0900
Labels:       app=event
Annotations:  diamanti.com/endpoint0: {"network":"blue","perfTier":"high"}
              kubectl.kubernetes.io/last-applied-configuration:
                {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{"diamanti.com/endpoint0":"{\"network\":\"blue\",\"perfTier\":\"high\"}"},"label...
              kubernetes.io/psp: collecting
Status:       Running  ## POD 상태
IP:           10.10.100.19
Containers:
  event-simulator:
    Container ID:   docker://454558ccbff3d65abcd93dd8200c6a74cd7b3e8973e5780f9f40b2322abcf50a
    Image:          kodekloud/event-simulator ## Image 정보
    Image ID:       docker-pullable://docker.io/kodekloud/event-simulator@sha256:1e3e9c72136bbc76c96dd98f29c04f298c3ae241c7d44e2bf70bcc209b030bf9
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 16 Jun 2020 09:23:37 +0900
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-4wtst (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  default-token-4wtst:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-4wtst
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m40s  default-scheduler  Successfully assigned default/event-simulator-pod to dia02
  Normal  Pulling    6m39s  kubelet, dia02     Pulling image "kodekloud/event-simulator"
  Normal  Pulled     6m29s  kubelet, dia02     Successfully pulled image "kodekloud/event-simulator"
  Normal  Created    6m29s  kubelet, dia02     Created container event-simulator
  Normal  Started    6m29s  kubelet, dia02     Started container event-simulator
  ```
  
### POD 뿐만 아니라 Service, Node 등 다양한 Cluster Object 상세 정보 확인 가능 
소스 코드 : [Service 예시](11.Service/headless-svc.yml)

서비스 상세 정보
```
kc apply -f headless-svc.yml

spkr@erdia22:~/02.k8s_code/01.POD$ kc describe svc web-svc
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

Node 상세 정보 
```
spkr@erdia22:~/02.k8s_code/01.POD$ kc describe nodes dia01
Name:               dia01
Roles:              <none>
Labels:             beta.diamanti.com/runc=true
                    beta.diamanti.com/runtime-engine=docker
                    beta.kubernetes.io/arch=amd64
                    beta.kubernetes.io/os=linux
                    kubernetes.io/arch=amd64
                    kubernetes.io/hostname=dia01
                    kubernetes.io/os=linux
Annotations:        csi.volume.kubernetes.io/nodeid: {"dcx.csi.diamanti.com":"dia01","dcx.nfs.csi.diamanti.com":"dia01"}
                    node.alpha.kubernetes.io/ttl: 0
CreationTimestamp:  Fri, 22 May 2020 10:51:58 +0900
Taints:             <none>
Unschedulable:      false
Conditions:
  Type             Status  LastHeartbeatTime                 LastTransitionTime                Reason                       Message
  ----             ------  -----------------                 ------------------                ------                       -------
  MemoryPressure   False   Tue, 16 Jun 2020 09:34:15 +0900   Fri, 22 May 2020 10:51:57 +0900   KubeletHasSufficientMemory   kubelet has sufficient memory available
  DiskPressure     False   Tue, 16 Jun 2020 09:34:15 +0900   Fri, 29 May 2020 14:21:41 +0900   KubeletHasNoDiskPressure     kubelet has no disk pressure
  PIDPressure      False   Tue, 16 Jun 2020 09:34:15 +0900   Fri, 22 May 2020 10:51:57 +0900   KubeletHasSufficientPID      kubelet has sufficient PID available
  Ready            True    Tue, 16 Jun 2020 09:34:15 +0900   Fri, 22 May 2020 10:51:58 +0900   KubeletReady                 kubelet is posting ready status
Addresses:
  InternalIP:  192.168.200.101
  Hostname:    dia01
Capacity:
 cpu:                40
 ephemeral-storage:  65504Mi
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             131737728Ki
 pods:               110
Allocatable:
 cpu:                40
 ephemeral-storage:  61817329972
 hugepages-1Gi:      0
 hugepages-2Mi:      0
 memory:             131635328Ki
 pods:               110
System Info:
 Machine ID:                 fb11e7c9b5f544878ab449af2c16a3bb
 System UUID:                80DB37F2-9F88-E711-906E-0012795D9712
 Boot ID:                    9e5645c6-de50-4e2c-b887-47b13dd5104f
 Kernel Version:             3.10.0-957.el7.x86_64
 OS Image:                   CentOS Linux 7 (Core)
 Operating System:           linux
 Architecture:               amd64
 Container Runtime Version:  docker://1.13.1
 Kubelet Version:            v1.15.10
 Kube-Proxy Version:         v1.15.10
Non-terminated Pods:         (17 in total)
  Namespace                  Name                                               CPU Requests  CPU Limits  Memory Requests  Memory Limits  AGE
  ---------                  ----                                               ------------  ----------  ---------------  -------------  ---
  diamanti-system            collectd-v0.8-wck72                                0 (0%)        0 (0%)      0 (0%)           0 (0%)         24d
  diamanti-system            csi-diamanti-driver-qslv2                          0 (0%)        0 (0%)      0 (0%)           0 (0%)         24d
  diamanti-system            csi-external-attacher-6bbc9d4bbd-kz9jh             0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d18h
  diamanti-system            csi-external-provisioner-957ff6577-8qk8c           0 (0%)        0 (0%)      0 (0%)           0 (0%)         5d18h
  diamanti-system            csi-external-resizer-9848cdf68-l7t7n               0 (0%)        0 (0%)      0 (0%)           0 (0%)         7d17h
  diamanti-system            csi-external-snapshotter-8c8959567-nf728           0 (0%)        0 (0%)      0 (0%)           0 (0%)         7d17h
  diamanti-system            kvm-controller-fcb9c9476-wbvs8                     0 (0%)        0 (0%)      0 (0%)           0 (0%)         24d
  diamanti-system            nfs-csi-diamanti-driver-t8blw                      0 (0%)        0 (0%)      0 (0%)           0 (0%)         24d
  diamanti-system            prometheus-v1-1                                    0 (0%)        0 (0%)      1Gi (0%)         1Gi (0%)       24d
  haproxy-controller         haproxy-ingress-7857555856-nnrh7                   500m (1%)     0 (0%)      50Mi (0%)        0 (0%)         3d23h
  ingress                    myingress01-kubernetes-ingress-589649756c-7jp5v    100m (0%)     0 (0%)      64Mi (0%)        0 (0%)         10d
  instavote                  redis-85c6fff7b7-th68b                             0 (0%)        0 (0%)      0 (0%)           0 (0%)         4d23h
  instavote                  vote-7b4c45f68d-6ttcw                              100m (0%)     200m (0%)   50Mi (0%)        250Mi (0%)     4d23h
  kube-system                coredns-54d89499d4-vr5bz                           100m (0%)     0 (0%)      70Mi (0%)        170Mi (0%)     24d
  kube-system                metrics-server-v1-5d46b6d959-2sjfl                 0 (0%)        0 (0%)      0 (0%)           0 (0%)         24d
  kube-system                tiller-deploy-5668df8bc4-s4b7m                     250m (0%)     500m (1%)   256Mi (0%)       512Mi (0%)     3d23h
  test                       mariadb-test-0                                     2 (5%)        0 (0%)      8Gi (6%)         0 (0%)         5d
Allocated resources:
  (Total limits may be over 100 percent, i.e., overcommitted.)
  Resource           Requests     Limits
  --------           --------     ------
  cpu                3050m (7%)   700m (1%)
  memory             9706Mi (7%)  1956Mi (1%)
  ephemeral-storage  0 (0%)       0 (0%)
Events:              <none>
```
