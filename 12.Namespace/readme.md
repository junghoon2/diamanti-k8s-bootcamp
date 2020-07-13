# Kubernetes Namespace
- ### What: Namespace(이름 공간), Kubernetes 내부적으로 사용하는 논리 그룹 단위 
- ### Why/When : 서로 다른 Namesapce POD 간 통신을 위하여 Namespace DNS 지정 필요
- ### 개별 Namespace 간 CPU/Memory 등 Resource 할당 가능 
- ### How : Diamanti는 Namespace 조회/변경을 위한 별도 명령어 Set 제공(dctl namespace ~) 

### Namespace 생성 및 조회

```
spkr@erdia22:~/02.k8s_code/01.POD$ kc create namespace prod-team1
namespace/prod-team1 created

spkr@erdia22:~/02.k8s_code/01.POD$ kc get namespaces
NAME                 STATUS   AGE
default              Active   26d
diamanti-system      Active   26d
kube-node-lease      Active   26d
kube-public          Active   26d
kube-system          Active   26d
prod-team1           Active   3s
```

### 현재 Namespace 조회 및 변경
- 조회는 get, 변경은 set 
```
spkr@erdia22:~/02.k8s_code/01.POD$ dctl namespace get
Namespace:                default

spkr@erdia22:~/02.k8s_code/01.POD$ dctl namespace set prod-team1

spkr@erdia22:~/02.k8s_code/01.POD$ dctl namespace get
Namespace:                prod-team1
```

- 명령어 전체 옵션
```
spkr@erdia22:~/02.k8s_code/01.POD$ dctl namespace
NAME:
   dctl namespace - Manage namespace for the current user context; see also 'kubectl config current-context'

USAGE:
   dctl namespace command [command options] [arguments...]

COMMANDS:
     list  List namespaces available to the current user
     set   Set namespace for the current user context
     get   get namespace for the current user context

OPTIONS:
   --help, -h  show help
```

### 다른 Namespace Object 조회 
- -n(or --namespace) 옵션 사용   
```
spkr@erdia22:~/02.k8s_code/01.POD$ kc get pod -n kube-system
NAME                                 READY   STATUS    RESTARTS   AGE
coredns-54d89499d4-98lqg             1/1     Running   0          4d22h
coredns-54d89499d4-tn9t9             1/1     Running   0          6d22h
coredns-54d89499d4-vr5bz             1/1     Running   0          26d
helm-chart-687577f867-9c6jh          1/1     Running   0          6d22h
metrics-server-v1-5d46b6d959-2sjfl   1/1     Running   0          26d
novnc-547484d7df-r7zvm               1/1     Running   0          6d22h
tiller-deploy-5668df8bc4-s4b7m       1/1     Running   0          5d3h

spkr@erdia22:~/02.k8s_code/01.POD$ kc get svc -n kube-system
NAME             TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
coredns          ClusterIP   10.0.0.10    <none>        53/UDP,53/TCP   26d
helm-chart       ClusterIP   None         <none>        80/TCP          26d
metrics-server   ClusterIP   10.0.0.65    <none>        443/TCP         26d
novnc            ClusterIP   None         <none>        80/TCP          26d
tiller-deploy    ClusterIP   None         <none>        44134/TCP       26d
```

### 현재 Namespace 내 POD 생성 또는 특정 Namespace 지정 
- YAML 파일 namespace 옵션 지정하지 않으면 현재 namespace으로 POD 생성

  namespace 옵션을 지정하면 해당 namespace로 POD 생성

소스 코드 : [Without Namespace POD](./nginx-wo-ns-pod.yml)

소스 코드 : [With Namespace POD](./nginx-ns-pod.yml)

```
vi nginx-ns-pod.yml

(...)
metadata:
  annotations:
    diamanti.com/endpoint0: '{"network":"blue","perfTier":"high"}'
  name: nginx
  namespace: test  # 원하는 Namespace 지정 
(...)

spkr@erdia22:~/02.k8s_code/01.POD$ kc apply -f nginx-wo-ns-pod.yml
pod/nginx created

spkr@erdia22:~/02.k8s_code/01.POD$ kc get pod
NAME    READY   STATUS              RESTARTS   AGE
nginx   0/1     ContainerCreating   0          2s

spkr@erdia22:~/02.k8s_code/01.POD$ kc apply -f nginx-ns-pod.yml
pod/nginx created

spkr@erdia22:~/02.k8s_code/01.POD$ kc get pod -n test
NAME             READY   STATUS    RESTARTS   AGE
nginx            1/1     Running   0          34s
```
