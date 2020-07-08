# Kubernetes 클러스터 설치
- ### 복잡한 k8s 클러스터 설치 과정 없이 DIAMANTI는 S/W + H/W 사전 설치된 Appliance로 형태로 제공
- ### NTP, Mgt/컨테이너 네트워크 IP 등의 기본 정보 입력 후 5분 이내 클러스터 구성 가능

## 클러스터 설치
- ### 명령어 예시에 따라 hostname, vip, storage vlan 등 정보 입력

```
spkr@erdia22:~$ dctl cluster create
Error: example usage -  dctl cluster create mycluster master-01,master-02,master03,node-01,node-02,node-03 --masters node-01,node-02,node-03 --vip 192.168.30.10 --poddns mycluster.diamanti.com --storage-vlan 2
```

## 클러스터 로그인
- ### Namespace에 따른 개인별 id/pwd(test01 ~ test09) 정보 입력

```
VIP 정보 확인

spkr@erdia22:~$ dctl -s [VIP] login
Name            : spkcluster
Virtual IP      : 192.168.200.100
Server          : spkcluster
WARNING: Thumbprint : b1 13 09 07 38 34 0d 9f 5e 11 44 08 8b 1f bd 97 74 e2 22 cd 48 8c 2a 5c 65 14 06 63 b1 60 c9 99
[CN:diamanti-signer@1590112299, OU:[], O=[] issued by CN:diamanti-signer@1590112299, OU:[], O=[]]
Configuration written successfully

(각 개인 별 USER/PASSWORD 정보 입력)

Username: 
Password:
Successfully logged in
```

- ### Namespace 및 USER 정보 확인
```
[test01@dia01 ~]$ kubectl config current-context
spkcluster:test01:test01
```

## 클러스터 상태 확인
- ### 전체 Cluster 상태 및 개별 Node 별 상태 확인 가능

```
spkr@erdia22:~$ dctl cluster status
Name            : spkcluster
UUID            : c6d720dc-9bce-11ea-b3d2-a4bf014f87ff
State           : Created
Version         : 2.4.0 (60)
Etcd State      : Healthy
Virtual IP      : 192.168.200.100
Storage VLAN    : 200
Pod DNS Domain  : cluster.local

NAME      NODE-STATUS   K8S-STATUS   ROLE      MILLICORES   MEMORY           STORAGE           IOPS       VNICS     BANDWIDTH   SCTRLS          LABELS

        LOCAL, REMOTE
dia01     Good          Good         master    2450/40000   9.38GiB/128GiB   1.05TB/3.05TB     20K/500K   3/63      500M/36G    1/64, 0/64      beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia01,kubernetes.io/os=linux
dia02     Good          Good         master    950/40000    1.43GiB/128GiB   880.61GB/3.05TB   0/500K     4/63      500M/36G    0/64, 0/64      beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia02,kubernetes.io/os=linux
dia03     Good          Good         master    110/40000    1.08GiB/128GiB   1.37TB/3.05TB     0/500K     3/63      0/36G       0/64, 0/64      beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia03,kubernetes.io/os=linux
dia04     Good          Good         worker    0/40000      0/128GiB         1.47TB/3.05TB     0/500K     2/63      500M/36G    0/64, 0/64      beta.diamanti.com/runc=true,beta.diamanti.com/runtime-engine=docker,beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=dia04,kubernetes.io/os=linux
```

- ### 노드 별 정보 확인
```
spkr@erdia22:~$ kc get nodes -o wide
NAME    STATUS   ROLES    AGE   VERSION    INTERNAL-IP       EXTERNAL-IP   OS-IMAGE                KERNEL-VERSION          CONTAINER-RUNTIME
dia01   Ready    <none>   18d   v1.15.10   192.168.200.101   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://1.13.1
dia02   Ready    <none>   18d   v1.15.10   192.168.200.102   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://1.13.1
dia03   Ready    <none>   18d   v1.15.10   192.168.200.103   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://1.13.1
dia04   Ready    <none>   18d   v1.15.10   192.168.200.104   <none>        CentOS Linux 7 (Core)   3.10.0-957.el7.x86_64   docker://1.13.1
```

## Default 컨테이너 데이터 네트워크 생성
- ### 다른 명령어와 동일하게 명령어 예시에 따라 subnet, start/end IP, gateway, vlan 정보 등 입력
```
spkr@erdia22:~/02.k8s_code$ dctl network create
Error: example usage -  dctl network create blue -s 192.168.30.0/24 --start 192.168.30.101 --end 192.168.30.200 -g 192.168.30.1 -v 2
spkr@erdia22:~/02.k8s_code$ dctl network create web01 -s 10.10.130.0/24 --start 10.10.130.11 --end 10.10.130.100 -g 10.10.130.1 -v 130
NAME      TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
web01     public    10.10.130.11    90        0         10.10.130.1   130
```

- ### 생성 후 해당 네트워크 IP 대역 확인**
```
spkr@erdia22:/mnt/c/Users/erdia$ dctl network list
NAME             TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
blue (default)   public    10.10.100.11    90        18        10.10.100.1   100
ingress          public    10.10.110.190   11        2         10.10.110.1   110
web              public    10.10.120.11    90        0         10.10.120.1   120
web01            public    10.10.130.11    90        0         10.10.130.1   130
```
