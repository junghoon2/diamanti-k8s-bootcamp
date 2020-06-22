# Kubernetes Volume Snapshot 
- ### Diamanti CSI 기능으로 Snapshot 및 Volume Replication 제공 
- ### Volume -> Snapshot -> Snapshot에서 Replication Volume 생성 순으로 진행 

### Snapshot 검증 용 PVC, POD 생성

소스 코드 : [high2m-pvc](./high2m-pvc.yml), [date-pvc-deploy](./date-pvc-deploy.yml)

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc apply -f high2m-pvc.yml
persistentvolumeclaim/snap-pvc created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc apply -f date-pvc-deploy.yml
deployment.apps/date-deploy created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc get pod,pvc
NAME                              READY   STATUS    RESTARTS   AGE
pod/date-deploy-6cd8db7b5-r52d6   1/1     Running   0          6s

NAME                                                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
persistentvolumeclaim/mariadb-data-mariadb-test-0   Bound    pvc-a6451f03-349d-4168-9f77-3d2de599a248   350Gi      RWO            high           20d
persistentvolumeclaim/snap-pvc                      Bound    pvc-306931e6-2c03-4cb0-8cc5-618c2b2bef34   10Gi       RWO            high2m         11s
```

### Volume 확인
- 10초 간격으로 Date 로그 생성 
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc exec -it date-deploy-6cd8db7b5-r52d6 -- bash

[root@date-deploy-6cd8db7b5-r52d6 /]# cat /data/pod-out.txt
Mon Jun 22 02:19:17 UTC 2020
Mon Jun 22 02:19:27 UTC 2020
Mon Jun 22 02:19:37 UTC 2020
Mon Jun 22 02:19:47 UTC 2020
Mon Jun 22 02:19:57 UTC 2020
```

### Snapshot 생성
- snapshot은 dctl snapshot 자체 명령어 이용
```
Snapshot 생성을 위하여 PV 이름 확인

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mariadb-data-mariadb-test-0   Bound    pvc-a6451f03-349d-4168-9f77-3d2de599a248   350Gi      RWO            high           20d
snap-pvc                      Bound    pvc-306931e6-2c03-4cb0-8cc5-618c2b2bef34   10Gi       RWO            high2m         76s

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ dctl snapshot create snap-pv --src  pvc-306931e6-2c03-4cb0-8cc5-618c2b2bef34
NAME      SIZE      NODE      LABELS    PARENT                                     PHASE     AGE
snap-pv   0         []        <none>    pvc-306931e6-2c03-4cb0-8cc5-618c2b2bef34   Pending

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ dctl snapshot list
NAME       SIZE      NODE      LABELS    PARENT                                     PHASE       AGE
snap-pv    10.77GB   [dia04]   <none>    pvc-306931e6-2c03-4cb0-8cc5-618c2b2bef34   Available   31s
```

### Snapshot으로 Volume 생성
- snapshot으로 PV 생성
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ dctl volume create snap-vol --src snap-pv
NAME       SIZE      NODE      LABELS    PHASE     STATUS    ATTACHED-TO   DEVICE-PATH   PARENT    AGE
snap-vol   10.77GB   []        <none>    Pending                                         snap-pv   0s

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ dctl volume get snap-vol
NAME       SIZE      NODE      LABELS    PHASE     STATUS      ATTACHED-TO   DEVICE-PATH   PARENT    AGE
snap-vol   10.77GB   [dia04]   <none>    -         Available                               snap-pv   9s
```

### Snapshot PV으로 PVC 생성

소스 코드 : [snap-pv-pvc](./snap-pv-pvc.yml)

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc apply -f snap-pv-pvc.yml
persistentvolumeclaim/snap-pvc02 created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
mariadb-data-mariadb-test-0   Bound    pvc-a6451f03-349d-4168-9f77-3d2de599a248   350Gi      RWO            high           20d
snap-pvc                      Bound    pvc-306931e6-2c03-4cb0-8cc5-618c2b2bef34   10Gi       RWO            high2m         4m8s
snap-pvc02                    Bound    snap-vol                                   10Gi       RWO                           2s
```

### 해당 PVC를 포함하는 POD 생성

소스 코드 : [busybox-pvc-pod](./busybox-pvc-pod.yml)

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc apply -f busybox-pvc-pod.yml
pod/busybox created
```

### Snapshot Data 확인
- POD 실행하여 이전 snapshot data 확인
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc exec -it busybox -- sh
/ # cat /data/pod-out.txt
Mon Jun 22 02:19:17 UTC 2020
Mon Jun 22 02:19:27 UTC 2020
Mon Jun 22 02:19:37 UTC 2020
Mon Jun 22 02:19:47 UTC 2020
Mon Jun 22 02:19:57 UTC 2020
Mon Jun 22 02:20:07 UTC 2020
Mon Jun 22 02:20:17 UTC 2020
Mon Jun 22 02:20:27 UTC 2020
Mon Jun 22 02:20:37 UTC 2020
Mon Jun 22 02:20:47 UTC 2020
```

