# Kubernetes Resource Request Limit

- ### 같은 Node 내 다른 POD에 성능 영향을 끼치지 않도록 개별 POD 별 cpu/memory 사용량 Limit 설정 기능(limits)
- ### POD Scheduling 시 요청 자원량 이상의 자원이 있는 Node로 할당이 필요한 경우 사용(requests). 예를 들어 DB 등의 중요 Application은 항상 8CPU 이상의 여유가 있는 Node에 할당이 필요한 경우 사용


### CPU 단위
쿠버네티스의 CPU 1개는 클라우드 공급자용 vCPU/Core 1개와 베어메탈 인텔 프로세서에서의 1개 하이퍼스레드에 해당(1,000m=1CPU)

### CPU Limits 설정
소스 코드 : [cpu-stress-limit-pod](./cpu-stress-limit-pod.yml)

```
vi cpu-stress-limit-pod.yml

(...)
    resources:
      limits:
        cpu: "1"
      requests:
        cpu: "0.5"
    args:
    - -cpus
    - "2"
```

Argument로 cpu 사용량을 '2' 로 설정. 하지만 limits 설정이 '1'로 되어 1이상의 cpu를 사용하지 못함.

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/20.ResourceRequestLimit$ kc apply -f cpu-stress-limit-pod.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/20.ResourceRequestLimit$ kc top pod cpu-demo
NAME       CPU(cores)   MEMORY(bytes)
cpu-demo   1001m        1Mi
```

(POD Resource 사용량 확인은 kubectl top 명령어로 확인)

CPU 사용량은 1001m(milli core), 1 Core로 Argument 2 Core 사용하지 못 함.  

### CPU Requests 설정
소스 코드 : [cpu-stress-request-pod](./cpu-stress-request-pod.yml)

```
vi cpu-stress-request-pod.yml

(...)
    resources:
      limits:
        cpu: "100"
      requests:
        cpu: "100"
```

CPU 요청 용량(requests)으로 100 CPU 이상의 Node가 할당되도록 요청.

하지만 100 CPU 이상의 Node가 없어 Scheduling 되지 않고 Pending.

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/20.ResourceRequestLimit$ kc get pod
NAME         READY   STATUS    RESTARTS   AGE
cpu-demo     1/1     Running   0          17m
cpu-demo-2   0/1     Pending   0          12m

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/20.ResourceRequestLimit$ kc describe pod cpu-demo-2
Name:         cpu-demo-2
(...)
Events:
  Type     Reason            Age                From               Message
  ----     ------            ----               ----               -------
  Warning  FailedScheduling  55s (x9 over 12m)  default-scheduler  0/4 nodes are available: 4 Insufficient cpu.
```

(describe로 상세 메시지 확인 가능) 

참조

[ITChain Wordpress](https://itchain.wordpress.com/2018/05/16/kubernetes-resource-request-limit)

[Kube.io](https://kubernetes.io/docs/tasks/configure-pod-container/assign-cpu-resource)

