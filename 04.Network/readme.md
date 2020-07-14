# DIAMANTI Networking
- ### Diamanti는 SR-IOV를 이용하여 물리 서버의 가상 NIC를 바로 POD의 NIC로 할당
- ### POD 네트워크 성능 향상 및 네트워크 장애 처리 과정의 단순화
- ### VM 및 타 Kubernetes 클러스터와 다르게 Overlay/NAT 등의 중간 과정이 필요 없음
- ### 서비스 별 IP 대역을 그룹화하여(ex: web, db, dmz 등) 개별 POD 별 특정 IP 할당 가능

현재 네트워크 IP 대역 그룹 확인
```
spkr@erdia22:~/02.k8s_code/01.POD$ dctl network list
NAME             TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
blue (default)   public    10.10.100.11    90        23        10.10.100.1   100
ingress          public    10.10.110.190   11        2         10.10.110.1   110
```

신규 네트워크 IP 대역 그룹 생성
```
spkr@erdia22:~/02.k8s_code/01.POD$ dctl network create
Error: example usage -  dctl network create blue -s 192.168.30.0/24 --start 192.168.30.101 --end 192.168.30.200 -g 192.168.30.1 -v 2
```

예제 명령어에 따라 -s Subnet, --start/--end 시작/마지막 IP, -g Gateway, -v Vlan 정보 입력하여 신규 네트워크 IP 대역 생성
```
spkr@erdia22:~/02.k8s_code/01.POD$ dctl network create web -s 10.10.120.0/24 --start 10.10.120.11 --end 10.10.120.100 -g 10.10.120.1 -v 120
NAME      TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
web       public    10.10.120.11    90        0         10.10.120.1   120
spkr@erdia22:~/02.k8s_code/01.POD$ dctl network list
NAME             TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
blue (default)   public    10.10.100.11    90        23        10.10.100.1   100
ingress          public    10.10.110.190   11        2         10.10.110.1   110
web              public    10.10.120.11    90        0         10.10.120.1   120
```

### POD 네트워크 IP 대역 지정

소스 코드 : [WEB IP 대역 지정](./nginx-network-pod.yml)

신규 생성된 web IP 대역(10.10.120.0/24)으로 nginx POD IP 할당
```
vi nginx-network-pod.yml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    diamanti.com/endpoint0: '{"network":"web","perfTier":"high"}'  ## 생성한 'web' 네트워크 지정
  name: nginx
spec:
  containers:
  - name: nginx-pod
    image: nginx

kc apply -f nginx-network-pod.yml

spkr@erdia22:~/02.k8s_code/01.POD$ kc get pod -o wide
NAME                                READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
centos7                             1/1     Running   0          22h   10.10.100.27   dia02   <none>           <none>
event-simulator-pod                 1/1     Running   0          35m   10.10.100.19   dia02   <none>           <none>
nginx                               1/1     Running   0          11s   10.10.120.11   dia02   <none>           <none>
```

신규 생성된 POD 용도로 하나의 IP가 사용됨 (USED 1)
```
spkr@erdia22:~/02.k8s_code/01.POD$ dctl network list
NAME             TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
blue (default)   public    10.10.100.11    90        22        10.10.100.1   100
ingress          public    10.10.110.190   11        2         10.10.110.1   110
web              public    10.10.120.11    90        1         10.10.120.1   120
```

### SR-IOV POD Network

물리 서버의 Port의 NAT 설정 없이 바로 POD NIC로 바로 접속 가능  
추가 NodePort 등의 Service 설정없이 curl로 해당 POD 바로 접속 가능(SR-IOV 가상 NIC 사용)
```
spkr@erdia22:~/02.k8s_code/01.POD$ curl -I 10.10.120.11
HTTP/1.1 200 OK
Server: nginx/1.19.0
Date: Tue, 16 Jun 2020 01:06:05 GMT
Content-Type: text/html
Content-Length: 612
Last-Modified: Tue, 26 May 2020 15:00:20 GMT
Connection: keep-alive
ETag: "5ecd2f04-264"
Accept-Ranges: bytes

spkr@erdia22:~/02.k8s_code/01.POD$ ping -c 1 10.10.120.11
PING 10.10.120.11 (10.10.120.11) 56(84) bytes of data.
64 bytes from 10.10.120.11: icmp_seq=1 ttl=63 time=4.38 ms

--- 10.10.120.11 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 4.389/4.389/4.389/0.000 ms
```

[참고자료 - Diamanti SR-IOV 네트워크](https://blog.naver.com/hoon295/221971834254)
