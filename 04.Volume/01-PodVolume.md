# DIAMANTI Kubernetes Volume
- ### NVMe Disk Kubernetes Volume 사용
- ### Diamanti 자체 CSI(Container Storage Interface) 드라이버 제공

### Storage Class 

소스 코드 : [StorageClass](./high2m-sc.yml)
```
vi high2m-sc.yml

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: high2m
parameters:
  fsType: xfs  ## ext4 등 FileType 선택 가능 
  mirrorCount: "2"  ## Volume Mirror 설정, 1/2/3 copy(최대 3) 설정 가능 
  perfTier: high  
provisioner: dcx.csi.diamanti.com  # Diamanti 자체 CSI 제공 
reclaimPolicy: Delete
volumeBindingMode: Immediate
allowVolumeExpansion: true  ## Volume 생성 후 용량 확장 가능
```

Storage Class 생성(sc for StorageClass)
```
kc apply -f high2m-sc.yml

spkr@erdia22:~/02.k8s_code/11.Storage$ kc get sc
NAME                       PROVISIONER            AGE
best-effort (default)      dcx.csi.diamanti.com   24d
high2m                     dcx.csi.diamanti.com   5d19h
(...)

spkr@erdia22:~/02.k8s_code/11.Storage$ kc describe sc high2m
Name:            high2m
IsDefaultClass:  No
Annotations:     kubectl.kubernetes.io/last-applied-configuration={"allowVolumeExpansion":true,"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"high2m"},"parameters":{"fsType":"xfs","mirrorCount":"2","perfTier":"high"},"provisioner":"dcx.csi.diamanti.com","reclaimPolicy":"Delete","volumeBindingMode":"Immediate"}

Provisioner:           dcx.csi.diamanti.com
Parameters:            fsType=xfs,mirrorCount=2,perfTier=high
AllowVolumeExpansion:  True
MountOptions:          <none>
ReclaimPolicy:         Delete
VolumeBindingMode:     Immediate
Events:                <none>
```

### PVC(Persistent Volume Claim)

소스 코드 [PVC](./high2m-pvc.yml)
```
vi high2m-pvc.yml

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: perf-pvc
#  namespace: diamanti-system
spec:
  accessModes:
  - ReadWriteOnce  ## block accessmode 지정 
  resources:
    requests:
      storage: 10Gi  ## 용량 지정 
  storageClassName: "high2m"  ## SC 이름 지정
```

PVC 생성 
```
kc apply -f high2m-pvc.yml

spkr@erdia22:~/02.k8s_code/11.Storage$ kc get pvc
NAME                          STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
perf-pvc                      Bound    pvc-e0d2afc4-0ed6-470f-9461-a1354c4edddf   10Gi       RWO            high2m         3s
(...)
```

### POD 볼륨 할당(PVC 이용)
소스 코드 [Deploy](./date-pvc-deploy.yml)

```
vi date-pvc-deploy.yml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: date-mirror-deploy
  labels:
    app: date-mirror
spec:
  replicas: 1
  selector:
    matchLabels:
      app: date-mirror
  template:    
    metadata:
      labels:
        app: date-mirror
    spec:
      containers:
      - name: date-pod
        image: centos:7.5.1804
        command:
        - "/bin/sh"
        - "-c"
        - "while true; do date >> /data/pod-out.txt; cd /data; sync; sync; sleep 10; done"
        volumeMounts:
        - name: date-pvc
          mountPath: /data
      volumes:
      - name: date-pvc
        persistentVolumeClaim:
          claimName: perf-pvc  ## PVC 이름 지정
```

볼륨 설정이 포함된 POD Deploy 
```
kc apply -f date-pvc-deploy.yml

spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod
NAME                                 READY   STATUS    RESTARTS   AGE
centos7                              1/1     Running   0          23h
date-mirror-deploy-d9c75d75d-9bg8c   1/1     Running   0          5s
```

POD 내 Volume 확인
. /data Mount Point로 NVMe volume 마운트 확인 가능
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc exec -it date-mirror-deploy-d9c75d75d-9bg8c -- bash

[root@date-mirror-deploy-d9c75d75d-9bg8c /]# df -Th
Filesystem                        Type     Size  Used Avail Use% Mounted on
overlay                           overlay  447G   24G  424G   6% /
tmpfs                             tmpfs     63G     0   63G   0% /dev
tmpfs                             tmpfs     63G     0   63G   0% /sys/fs/cgroup
/dev/nvme1n1                      xfs       11G   33M   10G   1% /data
/dev/mapper/centos_diamanti-var   xfs       64G  317M   64G   1% /etc/hosts
/dev/mapper/docker--vg-docker--lv xfs      447G   24G  424G   6% /run/secrets
shm                               tmpfs     64M     0   64M   0% /dev/shm
tmpfs                             tmpfs     63G   12K   63G   1% /run/secrets/kubernetes.io/serviceaccount
tmpfs                             tmpfs     63G     0   63G   0% /proc/acpi
tmpfs                             tmpfs     63G     0   63G   0% /proc/scsi
tmpfs                             tmpfs     63G     0   63G   0% /sys/firmware
```

정상적으로 File Write 가능 
```
[root@date-mirror-deploy-d9c75d75d-9bg8c /]# cat /data/pod-out.txt
Tue Jun 16 02:01:14 UTC 2020
Tue Jun 16 02:01:24 UTC 2020
Tue Jun 16 02:01:34 UTC 2020
Tue Jun 16 02:01:44 UTC 2020
```

Volume 상세 정보 확인
. Diamanti에서는 Volume 관련 자체 명령어 Set(dctl volume ) 제공
. Volume Mirror 상태 등 확인 가능 
```
spkr@erdia22:~/02.k8s_code/04.Deploy$ dctl volume describe pvc-e0d2afc4-0ed6-470f-9461-a1354c4edddf
Name                                          : pvc-e0d2afc4-0ed6-470f-9461-a1354c4edddf
Size                                          : 10.77GB
Encryption                                    : false
Node                                          : [dia02 dia01]
Label                                         : diamanti.com/pod-name=default/date-mirror-deploy-d9c75d75d-9bg8c
Node Selector                                 : <none>
Phase                                         : Available
Status                                        : Attached
Attached-To                                   : dia02
Device Path                                   : /dev/nvme1n1
Age                                           : 9m
Perf-Tier                                     : high
Mode                                          : Filesystem
Fs-Type                                       : xfs
Scheduled Plexes / Actual Plexes              : 2/2

Plexes:
          NAME                                          NODES     STATE     CONDITION   OUT-OF-SYNC-AGE   RESYNC-PROGRESS   DELETE-PROGRESS
          ----                                          -----     -----     ---------   ---------------   ---------------   ---------------
          pvc-e0d2afc4-0ed6-470f-9461-a1354c4edddf.p0   dia02     Up        InUse
          pvc-e0d2afc4-0ed6-470f-9461-a1354c4edddf.p1   dia01     Up        InUse
```

관련 정보: [Diamanti Stoage 할당](https://blog.naver.com/hoon295/221974330548)
