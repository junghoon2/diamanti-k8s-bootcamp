# kubectl

자주 사용하는 kubectl 명령어를 알아봅니다.

> **TIP** `alias kc='kubectl'`을 입력하면 편하게 명령어를 입력할 수 있습니다.

## 기본 명령어

- apply
  - Apply a configuration to a resource by filename or stdin
- get 
  - Display one or many resources
- describe
  - Show details of a specific resource or group of resources
- delete
  - Delete resources by filenames, stdin, resources and names, or by resources and label selector
- logs
  - Print the logs for a container in a pod
- exec
  - Execute a command in a container


## 명령어 vs YAML 파일

```
kubectl scale --replicas=3 rs/whoami
```

vs

```yml
apiVersion: apps/v1beta2
kind: ReplicaSet
metadata:
  name: whoami
spec:
  replicas: 3
```

## 기본 오브젝트

다음 오브젝트들을 생성하고 조회하고 삭제하는 작업을 합니다.

- node
- pod
- replicaset
- deployment
- service
- loadbalancer
- ingress
- volume
- configmap
- secret
- namespace

> 전체 오브젝트는 `kubectl api-resources`를 입력합니다.

## 다양한 사용법

특정 오브젝트를 조회하는 방법이 여러개 있습니다.

**get**
```
# pod, replicaset, deployment, service 조회
kubectl get all

# node 조회
kubectl get no
kubectl get node
kubectl get nodes

# 결과 포멧 변경
kubectl get nodes -o wide
kubectl get nodes -o yaml
kubectl get nodes -o json
kubectl get nodes -o json |
      jq ".items[] | {name:.metadata.name} + .status.capacity"

# YAML 파일 형태 저장
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/05.Deployment$ kc get deploy date-deploy -o yaml > /tmp/date-deploy.yml
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/05.Deployment$ cat /tmp/date-deploy.yml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  annotations:
 (...)
```

**describe**

```
# kubectl describe type/name
# kubectl describe type name
kubectl describe node <node name>
kubectl describe node/<node name>
```

**그외 자주 사용하는 명령어**

```
kubectl exec -it <POD_NAME>
kubectl logs -f <POD_NAME|TYPE/NAME>

kubectl apply -f <FILENAME>
kubectl delete -f <FILENAME>
```

**출처**

- [subicura Github](https://github.com/subicura/workshop-k8s-basic)

