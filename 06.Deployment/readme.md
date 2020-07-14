# Kubernetes Deployment

- ### 일반적으로 상태가 없는(Stateless) POD를 배포하는 기본 컨트롤러
- ### 배포 시 POD의 생성 및 삭제 숫자 등을 정의 할 수 있는 RollingUpdate 설정 가능 

### POD 개수 조정하기
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc create deployment nginx --image=nginx
deployment.apps/nginx created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc scale deployment nginx --replicas=5
deployment.extensions/nginx scaled
```

### Rollout History 확인
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc rollout history deployment nginx
deployment.extensions/nginx
REVISION  CHANGE-CAUSE
1         <none>
2         <none>
```

### Rollout 원복
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ kc rollout undo deployment nginx --to-revision=1
deployment.extensions/nginx rolled back
```



