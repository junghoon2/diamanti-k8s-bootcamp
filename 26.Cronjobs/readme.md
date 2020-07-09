# Kubernetes JOB

- ### 계속 실행하는 작업이 아닌 한 번 실행하고 끝나는 JOB (HPC JOB 등) 등을 k8s 환경에서 실행

### JOB 설정
실행 완료 횟수(completion), 동시 작업 횟수(parallelism) 옵션 지정
: 병렬로 4개 작업 씩 20번 작업 수행 

```
vi job.yml

apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  completions: 20  # 실행 완료 횟수
  parallelism: 4  # 동시 실행 횟수
  template:
    metadata:
      name: pi
    spec:
      containers:
      - name: pi
        image: perl
        command: ["perl", "-Mbignum=bpi", "-wle", "print bpi(2000)"]
      restartPolicy: OnFailure
  backoffLimit: 4

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/26.Cronjobs$ kc apply -f job.yml
job.batch/pi created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/26.Cronjobs$ kc get pod
NAME                              READY   STATUS              RESTARTS   AGE
date-deploy-69988d7f9-qcnz2       1/1     Running             0          2d
nfs-pvc-deploy-68ff5ffbbc-zqszb   1/1     Running             0          2d
pi-496nl                          0/1     ContainerCreating   0          2s
pi-4xgxh                          0/1     Completed           0          54s
pi-9nxfq                          0/1     Completed           0          18s
pi-b7mh7                          0/1     Completed           0          28s
pi-bwx84                          1/1     Running             0          10s
pi-clvt4                          0/1     Completed           0          46s
pi-cp8l8                          0/1     Completed           0          28s
pi-d2h2z                          0/1     Completed           0          30s
pi-dpg82                          0/1     Completed           0          53s
pi-frldw                          0/1     Completed           0          60s
pi-hqsbc                          0/1     ContainerCreating   0          2s
pi-jq9sr                          0/1     Completed           0          34s
pi-kdn6x                          0/1     Completed           0          13s
pi-ks4vg                          1/1     Running             0          7s
pi-lbfbk                          0/1     Completed           0          22s
pi-rxkqt                          0/1     Completed           0          43s
pi-w9xvl                          0/1     Completed           0          57s
pi-wv65x                          0/1     Completed           0          41s
pi-xjkb9                          0/1     Completed           0          41s
ssh                               1/1     Running             0          44h
```
