# DIAMANTI User 정책
- ### 계정 별 Namespace 및 각 Component(Volume, POD 등) 별 권한(edit/view)을 다르게 할당하여 개별 User 별 권한 제어. RBAC(Role Based Access Control)
- ### 예를 들어 test 유저는 test 네임스페이스 안에서 POD 삭제 등의 기능이 가능하고 다른 네임스페이스는 가능하지 않도록 설정

### Namespace 및 Group 생성
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ kc create namespace test02
namespace/test02 created

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ dctl user group create test02-ns --role-list container-edit/test02,volume-edit
NAME        BUILT-IN   ROLE LIST                         EXTERNAL GROUP
test02-ns   false      container-edit/test02, required

container-edit/test02 지정하여 지정된 namespace 안에서만 container-edit 기능 가능
```

### 전체 Role List 조회
```
spkr@erdia22:~$ dctl user role list
NAME                BUILT-IN   SCOPE      API PERMISSIONS
allcontainer-edit   true       Cluster    cluster [GET] containers [GET] containersummary [GET] endpoints [GET] events [GET] namespaces [GET] perftiers [GET] pods [GET] podsummary [GET] volumeclaims [GET] volumeclaimsummary [GET]
(중략)
```

### User 생성
```
생성한 Group을 User로 할당

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/36.SnapshotReplication$ dctl user create test02 --local-auth --password Diamanti1! --group-list test02-ns
Name:         test02
Built-In:     false
Local-Auth:   true
Groups:       test02-ns
Roles:        container-edit/test02, required
Namespace:    default
```

### User 클러스터 로그인
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ dctl login -u test02
Name            : spkcluster
Virtual IP      : 172.17.16.160
Server          : spkcluster
WARNING: Thumbprint : 58 f8 79 60 d2 02 0d 99 9b 15 a6 e7 fd e8 16 32 47 04 1a 07 c5 9b af b5 77 7a 83 fb 5c 52 88 56
[CN:diamanti-signer@1592965310, OU:[], O=[] issued by CN:diamanti-signer@1592965310, OU:[], O=[]]
Password:
```

### User 클러스터, 계정, 네임스페이스 확인 
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc config current-context
spkcluster:test02:test02
```

### User 권한 확인
```
test02 Namespace에서는 POD 생성 가능  

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc create deployment nginx02 --image=nginx
deployment.apps/nginx02 created

하지만, 다른 네임스페이스(test01)에서는 생성 불가능

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc create deployment nginx02 --image=nginx -n test01
Error from server (Forbidden): deployments.apps is forbidden: User "test02" cannot create resource "deployments" in API group "apps" in the namespace "test01"

동일하게 클러스터 관리 권한이 필요한 node 정보는 조회 불가능 

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc get nodes
Error from server (Forbidden): nodes is forbidden: User "test02" cannot list resource "nodes" in API group "" at the cluster scope
```
