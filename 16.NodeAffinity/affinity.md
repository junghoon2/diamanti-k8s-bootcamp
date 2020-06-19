# Kubernetes Affinity
- ### affinity(밀접한 관계, 선호)
- ### POD Scheduling 시 원하는 노드에 할당 또는 제외하고 Scheduling 가능
- ### 특정 POD가 있는 Node를 제외하고 또는 선택해서 Scheduling
- ### 예를 들어 Redis Cache는 같은 Node에 2개 이상 실행하지 않게 하고 Web Server와 Redis를 같은 Node에 실행하도록 지정 가능 

### Label 설정
Scheduling 하기 전 먼저 Node에 이름(Label) 지정 

```
spkr@erdia22:/mnt/c/Users/erdia$ kc label nodes dia03 zone=a
node/dia03 labeled

spkr@erdia22:/mnt/c/Users/erdia$ kc label nodes dia04 zone=a
node/dia04 labeled

spkr@erdia22:/mnt/c/Users/erdia$ kc get nodes --show-labels
NAME    STATUS   ROLES    AGE   VERSION    LABELS
dia01   Ready    <none>   27d   v1.15.10   beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia01,kubernetes.io/os=linux
dia02   Ready    <none>   27d   v1.15.10   beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia02,kubernetes.io/os=linux
dia03   Ready    <none>   27d   v1.15.10   beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia03,kubernetes.io/os=linux,zone=a
dia04   Ready    <none>   27d   v1.15.10   beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia04,kubernetes.io/os=linux,zone=a
```

### Node Affinity 
해당 Label(zone=a) 노드에 POD Scheduing 

소스 코드 : [Node Affinity](./node-affinity-nginx-deploy.yml)

```
(...)
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: zone  ## Key 값 지정
                operator: In  ## In, NotIn, Exists, DoesNotExist, Gt, Lt 사용 가능
                values:
                - a  
```
Node Scheding 확인
```
kc apply -f node-affinity-nginx-deploy.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
nginx-deployment-6c9b7977db-5grpk   1/1     Running   0          31m   10.10.100.26   dia04   <none>           <none>
nginx-deployment-6c9b7977db-6bhdm   1/1     Running   0          31m   10.10.100.30   dia03   <none>           <none>
nginx-deployment-6c9b7977db-f64vt   1/1     Running   0          31m   10.10.100.15   dia03   <none>           <none>
nginx-deployment-6c9b7977db-sks4x   1/1     Running   0          31m   10.10.100.19   dia04   <none>           <none>
```

Label(zone, a) 지정된 dia03, dia04에만 POD Scheduing 됨 

### POD Anti-Affinity
특정 POD가 있는 Node를 선택해서 혹은 제외하고 POD SCheduling 가능 

소스 코드 : [Pod Affinity](./pod-affinity-redis-deploy.yml)
```
(...)
    spec:
      affinity:
        podAntiAffinity: ## POD 할당되지 않은 Node로 Scheduling
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app  ## Key 선택
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
```
Node Scheduing 확인
```
kc apply -f pod-affinity-redis-deploy.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
redis-cache-67786cc786-lp7l8        1/1     Running   0          15m   10.10.100.41   dia01   <none>           <none>
redis-cache-67786cc786-nqz7p        1/1     Running   0          15m   10.10.100.42   dia03   <none>           <none>
redis-cache-67786cc786-smhhc        1/1     Running   0          15m   10.10.100.40   dia02   <none>           <none>
```
중복되지 않고 서로 다른 Node(dia01/02/03)에 POD Scheduing 됨

Replica 8개 확장 시 Error 발생
: 노드에 이미 POD 실행 중이라 Scheduling 되지 않음 
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc scale deployment redis-cache --replicas=8
deployment.extensions/redis-cache scaled

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE     NOMINATED NODE   READINESS GATES
redis-cache-67786cc786-7sdgf        1/1     Running   0          13s   10.10.100.39   dia04    <none>           <none>
redis-cache-67786cc786-gmkfw        0/1     Pending   0          13s   <none>         <none>   <none>           <none>
redis-cache-67786cc786-lp7l8        1/1     Running   0          23m   10.10.100.41   dia01    <none>           <none>
redis-cache-67786cc786-m5xd4        0/1     Pending   0          13s   <none>         <none>   <none>           <none>
redis-cache-67786cc786-nqz7p        1/1     Running   0          23m   10.10.100.42   dia03    <none>           <none>
redis-cache-67786cc786-smhhc        1/1     Running   0          23m   10.10.100.40   dia02    <none>           <none>
redis-cache-67786cc786-xpfj7        0/1     Pending   0          13s   <none>         <none>   <none>           <none>
redis-cache-67786cc786-xtt6z        0/1     Pending   0          13s   <none>         <none>   <none>           <none>

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc describe pod redis-cache-67786cc786-gmkfw
Name:           redis-cache-67786cc786-gmkfw
(...)
  Type     Reason            Age                From               Message
  ----     ------            ----               ----               -------
  Warning  FailedScheduling  29s (x3 over 93s)  default-scheduler  0/4 nodes are available: 4 node(s) didn't match pod affinity/anti-affinity, 4 node(s) didn't satisfy existing pods anti-affinity rules.
```

### POD Affinity
같은 node에 POD 실행. 예를 들어 Web-server와 Redis을 같은 Node로 실행하기 원하는 경우

소스 코드 : 
```
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - web-store
            topologyKey: "kubernetes.io/hostname"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - store
            topologyKey: "kubernetes.io/hostname"
      containers:
      - name: web-app
        image: nginx:1.16-alpine


```

POD Scheduling
```
kc apply -f  pod-affinity-nginx-deploy.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/16.NodeAffinity$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP             NODE     NOMINATED NODE   READINESS GATES
redis-cache-67786cc786-lp7l8        1/1     Running   0          30m     10.10.100.41   dia01    <none>           <none>
redis-cache-67786cc786-nqz7p        1/1     Running   0          30m     10.10.100.42   dia03    <none>           <none>
redis-cache-67786cc786-smhhc        1/1     Running   0          30m     10.10.100.40   dia02    <none>           <none>
web-server-846dbbd6dd-dk94r         1/1     Running   0          28m     10.10.100.38   dia03    <none>           <none>
web-server-846dbbd6dd-vpwnq         1/1     Running   0          28m     10.10.100.14   dia02    <none>           <none>
web-server-846dbbd6dd-xl2z7         1/1     Running   0          28m     10.10.100.37   dia01    <none>           <none>
```

redis가 실행 중인 노드(dia01/02/03)에 web-server POD 실행 


참조 자료 : [POD Scheduing](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/)

           
