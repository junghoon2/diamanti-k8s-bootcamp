## 서버(Node) Down Test
### Kubernetes 클러스터는 Node Down 시 다른 Node에서 해당 Application(POD)를 자동 재기동하여 전체 Application 갯수를 항상 선언된 상태로 유지함

### POD 상태 확인
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -o wide
NAME                       READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
nginx01-6bdf767788-bthvn   1/1     Running   0          6m47s   10.10.100.30   dia02   <none>           <none>
nginx01-6bdf767788-shs7g   1/1     Running   0          34m     10.10.100.13   dia03   <none>           <none>
nginx01-6bdf767788-sw2jg   1/1     Running   0          19m     10.10.100.35   dia03   <none>           <none>
```

### 2번 Node(dia02) Down

drain(배출하다) 명령어 이용

```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc drain dia02
node/dia02 cordoned
error: unable to drain node "dia02", aborting command...

There are pending nodes to be drained:
 dia02
error: cannot delete DaemonSet-managed Pods (use --ignore-daemonsets to ignore): diamanti-system/collectd-v0.8-px5qs, diamanti-system/csi-diamanti-driver-c2xxw, diamanti-system/nfs-csi-diamanti-driver-s4vpz
```

다른 명령어와 동일하게 명령어 실행 시 error가 발생하여도 error 메시지로 바로 조치 가능

위 예제는 '--ignore-daemonsets' 옵션이 빠져서 에러 발생
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc drain dia02 --ignore-daemonsets
node/dia02 already cordoned
WARNING: ignoring DaemonSet-managed Pods: diamanti-system/collectd-v0.8-px5qs, diamanti-system/csi-diamanti-driver-c2xxw, diamanti-system/nfs-csi-diamanti-driver-s4vpz
evicting pod "tiller-deploy-5668df8bc4-2m4pz"
evicting pod "provisioner-7b58589b9d-j82sj"
evicting pod "alertmanager-0"
evicting pod "nginx01-6bdf767788-bthvn"
evicting pod "vote-7b4c45f68d-ngcb8"
evicting pod "coredns-54d89499d4-qf8ct"
evicting pod "prometheus-v1-2"
evicting pod "myingress01-kubernetes-ingress-589649756c-ltsf4"
evicting pod "haproxy-ingress-7857555856-879qt"
evicting pod "ingress-default-backend-54b95c875b-zww8f"
pod/haproxy-ingress-7857555856-879qt evicted
pod/provisioner-7b58589b9d-j82sj evicted
pod/nginx01-6bdf767788-bthvn evicted
pod/coredns-54d89499d4-qf8ct evicted
pod/vote-7b4c45f68d-ngcb8 evicted
pod/ingress-default-backend-54b95c875b-zww8f evicted
pod/alertmanager-0 evicted
pod/prometheus-v1-2 evicted
pod/myingress01-kubernetes-ingress-589649756c-ltsf4 evicted
pod/tiller-deploy-5668df8bc4-2m4pz evicted
node/dia02 evicted
```

### 2번 Node(dia02)에서 실행 중인 Application이 4번 Node(dia04)에서 자동 재기동 됨
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
nginx01-6bdf767788-9w9vd   1/1     Running   0          37s   10.10.100.19   dia04   <none>           <none>
nginx01-6bdf767788-shs7g   1/1     Running   0          37m   10.10.100.13   dia03   <none>           <none>
nginx01-6bdf767788-sw2jg   1/1     Running   0          22m   10.10.100.35   dia03   <none>           <none>
```

## Node 원복

uncordon(방역선) 명령어 사용
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get nodes
NAME    STATUS                     ROLES    AGE   VERSION
dia01   Ready                      <none>   20d   v1.15.10
dia02   Ready,SchedulingDisabled   <none>   20d   v1.15.10
dia03   Ready                      <none>   20d   v1.15.10
dia04   Ready                      <none>   20d   v1.15.10
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc uncordon dia02
node/dia02 uncordoned
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get nodes
NAME    STATUS   ROLES    AGE   VERSION
dia01   Ready    <none>   20d   v1.15.10
dia02   Ready    <none>   20d   v1.15.10
dia03   Ready    <none>   20d   v1.15.10
dia04   Ready    <none>   20d   v1.15.10
```

Node 원복 시 기존 Application이 자동으로 실행되지 않음 

### 추가 Application Deploy 시 해당 노드(dia02)로 Application 정상 배포됨

POD 20개 배표
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc scale deployment nginx01 --replicas=20
deployment.extensions/nginx01 scaled
```

각 노드 별 Application 수량 확인
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -o wide|grep dia01|wc -l
5
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -o wide|grep dia02|wc -l
5
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -o wide|grep dia03|wc -l
5
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod -o wide|grep dia04|wc -l
5
```

### Node 제거 후 다시 추가하면 정상적으로 개별 노드에 균등하게 POD 배분

Deployment 제거
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/05.Deployment$ kc get deployments.
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
date-deploy      1/1     1            1           24h
nfs-pvc-deploy   1/1     1            1           12d
nginx02          10/10   10           10          2d

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/05.Deployment$ kc delete deployments. nginx02
deployment.extensions "nginx02" deleted

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/05.Deployment$ kc get deployments.
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
date-deploy      1/1     1            1           24h
nfs-pvc-deploy   1/1     1            1           12d
```
