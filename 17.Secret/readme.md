# Kubernetes Secret
### MariaDB Password 등의 민감한 정보를 Kubernetes에서는 Secret Object를 사용하여 저장
### POD에서 secretRef 설정을 이용하여 해당 암호화 정보를 환경 변수로 사용 

- ### 암호화 문구 만들기
```
base64 util 사용하여 'root', 'password'에 대한 암호화 문 생성(먼저, 암호화하고 Secret으로 저장함) 

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ echo -n 'root'|base64
cm9vdA==

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ echo -n 'password'|base64
cGFzc3dvcmQ=
```

- ### Secret 생성
```
vi secret.yml

apiVersion: v1
kind: Secret
metadata:
  name: app-secret
data:
  DB_User: cm9vdA==
  DB_Password: cGFzc3dvcmQ=
```

DB_User, DB_Password Key 값에 대한 Value 값으로 암호화된 문구 적용

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/17.Secret$ kc apply -f secret.yml
secret/app-secret created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/17.Secret$ kc get secrets
NAME                  TYPE                                  DATA   AGE
app-secret            Opaque                                2      6s
default-token-pd8cz   kubernetes.io/service-account-token   3      16d
```
- ### Password 확인 방법

```
1줄로 확인

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/42.Kafka/kafka-bitnami$ kubectl get secret loki-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
LNfIBAURsIesq729Dfh8vpwSywEeMsCkDLCCX1hO
```


```
YAML 파일 추출 

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/46.argo$ k get secrets argocd-secret -o yaml
```

decode 실행 

```
[diamanti@diamanti1 ~]$ echo -n 'bXlzcWw=' | base64 --decode
mysql
[diamanti@diamanti1 ~]$ echo -n 'cGFzc3dvcmQ=' | base64 --decode
password
```

- ### POD Secret 환경 변수 적용
```
vi webapp-color-pod.yml

(...)
spec:
  containers:
  - name: simple-webapp-color
    image: kodekloud/simple-webapp
    envFrom:
    - secretRef:  # from Secret
        name: app-secret  # 생성한 Secret 이름
    ports:
    - containerPort: 80
```

- ### POD 실행을 통한 암호화된 환경 변수 확인
POD 안에서 복호화 된 상태의 해당 key 값에 대한 value 확인 가능  
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/17.Secret$ kc apply -f webapp-color-pod.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/17.Secret$ kc exec -it simple-webapp-color -- sh
/opt # echo $DB_User
root
/opt # echo $DB_Password
password
```
