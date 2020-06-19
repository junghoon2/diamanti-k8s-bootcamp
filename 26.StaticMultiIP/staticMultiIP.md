# POD 특정 IP & 복수 NIC 할당하기
- ### Diamanti는 자체 CNI 기능으로 POD 별 특정 IP 지정 또는 복수의 NIC 할당 가능

### 특정 IP를 지정하여 endpoint 생성
- name : ep1
- 다른 명령어와 동일하게 명령어 예시 참조
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/26.StaticMultiIP$ dctl network list
NAME             TYPE      START ADDRESS   TOTAL     USED      GATEWAY       VLAN      NETWORK-GROUP   ZONE
blue (default)   public    10.10.100.11    90        23        10.10.100.1   100
ingress          public    10.10.110.190   11        2         10.10.110.1   110
web              public    10.10.120.11    90        1         10.10.120.1   120

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ dctl endpoint create --help
NAME:
   dctl endpoint create - Create an endpoint

USAGE:
   dctl endpoint create [command options] [arguments...]

DESCRIPTION:
   dctl endpoint create ep1 -n blue -ns default

OPTIONS:
   --ip value, -i value           IP address
   --network value, -n value      Name of the network
   --labels value, -l value       Labels for the endpoint
   --namespace value, --ns value  Namespace for the endpoint (default: "default")

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ dctl endpoint create ep1 -n web --ip 10.10.120.91 --ns default
NAME      NAMESPACE   CONTAINER   NETWORK   IP                MAC       GATEWAY       VLAN      VF        PORT      NODE      LABELS
ep1       default                 web       10.10.120.91/24             10.10.120.1   120                                     <none>
```

### POD IP 할당

소스 코드 : [Nginx Endpoint POD](./nginx-endpoint-pod.yml)

- annotations > endpointId 지정
```
vi nginx-endpoint-pod.yml

apiVersion: v1
kind: Pod
metadata:
  annotations:
    diamanti.com/endpoint0: '{"endpointId":"ep1","perfTier":"high"}'
  name: nginx
spec:
  containers:
  - name: nginx-pod
    image: nginx
```

POD 생성 후 IP 확인
- POD IP(10.10.120.91) & Endpoint ep1 IP 동일 
```
kc apply -f nginx-endpoint-pod.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/26.StaticMultiIP$ kc get pod -o wide
NAME                                READY   STATUS        RESTARTS   AGE     IP             NODE    NOMINATED NODE   READINESS GATES
centos7                             1/1     Running       0          79m     10.10.100.39   dia02   <none>           <none>
nginx                               1/1     Running       0          22s     10.10.120.91   dia02   <none>           <none>
```

### 복수 IP 할당

소스 코드 : [Busybox Multi IP POD](./busybox-multiIP-pod.yml)

- annotations > endpoint0, endpoint1 지정
```
apiVersion: v1
kind: Pod
metadata:
  annotations:
    diamanti.com/endpoint0: '{"network":"web","perfTier":"high"}'
    diamanti.com/endpoint1: '{"network":"blue","perfTier":"high"}'
  name: busybox-multi-ip
(...)
```

POD 생성 후 IP 확인 
- 2개 NIC 생성(eth0, eth1)

```
kc apply -f busybox-multiIP-pod.yml

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/26.StaticMultiIP$ kc exec -it busybox-multi-ip -- sh
/ # ip a show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
3: mgmt0@if221: <BROADCAST,MULTICAST,UP,LOWER_UP,M-DOWN> mtu 1500 qdisc noqueue
    link/ether f6:52:23:e6:4d:bf brd ff:ff:ff:ff:ff:ff
    inet 172.20.0.141/24 scope global mgmt0
       valid_lft forever preferred_lft forever
4: eth0@enp129s2f2d2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1496 qdisc noqueue qlen 1000
    link/ether 8e:a2:00:61:a0:22 brd ff:ff:ff:ff:ff:ff
    inet 10.10.120.11/24 scope global eth0
       valid_lft forever preferred_lft forever
5: eth1@enp129s4f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1496 qdisc noqueue qlen 1000
    link/ether 8e:a2:00:61:a0:16 brd ff:ff:ff:ff:ff:ff
    inet 10.10.100.14/24 scope global eth1
       valid_lft forever preferred_lft forever
33: enp129s4f1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq qlen 1000
    link/ether 8e:a2:00:61:a0:16 brd ff:ff:ff:ff:ff:ff
50: enp129s2f2d2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq qlen 1000
    link/ether 8e:a2:00:61:a0:22 brd ff:ff:ff:ff:ff:ff
```
- Management NIC(mgmt) 와 Data NIC(eth0, eth1) 분리 


2개 IP 모두 Ping 가능
```
spkr@erdia22:~$ ping 10.10.120.11
PING 10.10.120.11 (10.10.120.11) 56(84) bytes of data.
64 bytes from 10.10.120.11: icmp_seq=1 ttl=63 time=4.78 ms
64 bytes from 10.10.120.11: icmp_seq=2 ttl=63 time=4.45 ms
^C
--- 10.10.120.11 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1001ms
rtt min/avg/max/mdev = 4.451/4.618/4.786/0.180 ms

spkr@erdia22:~$ ping 10.10.100.14
PING 10.10.100.14 (10.10.100.14) 56(84) bytes of data.
64 bytes from 10.10.100.14: icmp_seq=1 ttl=63 time=4.11 ms
64 bytes from 10.10.100.14: icmp_seq=2 ttl=63 time=4.88 ms
64 bytes from 10.10.100.14: icmp_seq=3 ttl=63 time=4.42 ms
^C
--- 10.10.100.14 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2001ms
rtt min/avg/max/mdev = 4.110/4.472/4.882/0.316 ms
```
