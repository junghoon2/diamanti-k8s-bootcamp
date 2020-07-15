# 기본 Kubernetes POD YAML File 

- ### YAML 파일을 이용하여 POD 생성(apply), 확인(get), 삭제(delete) 실습

YAML 파일 옵션 변경
```
apiVersion: v1
kind: Pod
metadata:
  annotations:
    diamanti.com/endpoint0: '{"network":"red","perfTier":"high"}'
  name: busybox  # POD 이름 지정 
spec:
  containers:
  - name: busybox-pod
    image: busybox:0.1  # 이미지 버전 지정, docker hub 등 tag 정보 지정
    command:
    - "/bin/sh"
    - "-c"
    - "sleep inf"
```


POD 생성
```
kc apply -f [FILE]

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc apply -f ssh-pod.yml
pod/ssh created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc get pod -o wide
NAME                              READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
date-deploy-69988d7f9-qcnz2       1/1     Running   0          3h45m   10.10.100.17   dia03   <none>           <none>
nfs-pvc-deploy-68ff5ffbbc-zqszb   1/1     Running   0          3h50m   10.10.100.19   dia02   <none>           <none>
nginx02-79799bc485-8d7lf          1/1     Running   0          27h     10.10.100.18   dia03   <none>           <none>
ssh                               1/1     Running   0          30s     10.10.100.30   dia04   <none>           <none>
```

POD 조회
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc get pod
NAME                              READY   STATUS             RESTARTS   AGE
busybox                           1/1     Running            1          5d17h
```

POD 삭제
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc delete pod busybox
pod "busybox" deleted

Examples:
  # Delete a pod using the type and name specified in pod.json.
  kubectl delete -f ./pod.json
```

삭제 시 시간 소요
. delete 옵션 지정으로 빠르게 삭제 가능
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc delete pod --help
Delete resources by filenames, stdin, resources and names, or by resources and label selector.

  # Delete resources from a directory containing kustomization.yaml - e.g. dir/kustomization.yaml.
  kubectl delete -k dir

  # Delete a pod based on the type and name in the JSON passed into stdin.
  cat pod.json | kubectl delete -f -

  # Delete pods and services with same names "baz" and "foo"
  kubectl delete pod,service baz foo

  # Delete pods and services with label name=myLabel.
  kubectl delete pods,services -l name=myLabel

  # Delete a pod with minimal delay
  kubectl delete pod foo --now

  # Force delete a pod on a dead node
  kubectl delete pod foo --grace-period=0 --force

  # Delete all pods
  kubectl delete pods --all
```

delete --now 옵션 지정
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc delete pod centos7 --now
pod "centos7" deleted

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc get pod
NAME                              READY   STATUS             RESTARTS   AGE
busybox                           1/1     Terminating        1          5d17h
```
