# 기본 Kubernetes POD YAML File 

### POD 생성
```
kc apply [FILE]

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc apply -f ssh-pod.yml
pod/ssh created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/01.Pod$ kc get pod -o wide
NAME                              READY   STATUS    RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
date-deploy-69988d7f9-qcnz2       1/1     Running   0          3h45m   10.10.100.17   dia03   <none>           <none>
nfs-pvc-deploy-68ff5ffbbc-zqszb   1/1     Running   0          3h50m   10.10.100.19   dia02   <none>           <none>
nginx02-79799bc485-8d7lf          1/1     Running   0          27h     10.10.100.18   dia03   <none>           <none>
ssh                               1/1     Running   0          30s     10.10.100.30   dia04   <none>           <none>
```
