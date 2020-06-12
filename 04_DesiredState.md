## Desired State
**kubernetes 핵심 개념으로 클러스터는 항상 요청하는 상태(desired state)를 자동으로 유지**

현재 deploy는 POD 3개로 선언됨

```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get deployments.
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
nginx01   3/3     3            3           26m
```

**POD 삭제**

```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc delete pod nginx01-6bdf767788-rvczs
pod "nginx01-6bdf767788-rvczs" deleted
```

**POD를 삭제하여도 자동으로 POD를 재기동하여 최초 선언한 상태인 3개로 유지**

```
spkr@erdia22:~/02.k8s_code/04.Deploy$ kc get pod
NAME                       READY   STATUS    RESTARTS   AGE
nginx01-6bdf767788-bthvn   1/1     Running   0          48s
nginx01-6bdf767788-shs7g   1/1     Running   0          28m
nginx01-6bdf767788-sw2jg   1/1     Running   0          13m
```

**Kubernetes는 Cluster를 자동으로 감시하여 기존 선언된 상태로 유지**
