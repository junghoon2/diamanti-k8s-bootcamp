# DIAMANTI Software Architecture
### Kubernetes Cluster는 Master Node는 ETCD, apiserver, controller manager, scheduler 실행 중
### Worker Node는 kubelet, kube-proxy, Container Runtime Engine 실행 중
### Diamanti는 추가로 Master Node는 Armada, Convoy Worker Node는 Bosun 실행 중
### Diamanti는 위 서비스가 System Service(systemctl) 형태로 실행 중

