# Daemonset

### 클러스터 전체 노드에 반드시 실행이 되어야 하는 POD 정의 용도
### 노드/POD 성능 수집, 로그 수집기 등에 사용 

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/04.Network$ kc get ds -A
NAMESPACE         NAME                      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
diamanti-system   collectd-v0.8             4         4         4       4            4           <none>          20d
diamanti-system   csi-diamanti-driver       4         4         4       4            4           <none>          20d
diamanti-system   nfs-csi-diamanti-driver   4         4         4       4            4           <none>          20d
```

디아만티는 성능 모니터링(collectd), 스토리지 관련 드라이버(csi, nfs-csi)가 DaemonSet으로 사용 중 
