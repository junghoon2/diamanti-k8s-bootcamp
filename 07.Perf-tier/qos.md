# Diamanti Performance Tier
- ### Diamanti는 운영 중 다른 POD의 시스템 사용량에 영향을 받지 않도록 QoS(Quality of Service) 기능 제공
- ### Performance Tier 형태로 사용되며 Minimum/Maximum IOPS, Bandwidth 설정 가능 

Noisyneighborhood 
![Noisy Neighborhood](./200617NoisyNeighborhood.png)

Performance Tier 조회
```
spkr@erdia22:~/hosts$ dctl perf-tier list
NAME          STORAGE IOPS   NETWORK BANDWIDTH   MAX STORAGE IOPS   MAX NETWORK BANDWIDTH   LABELS
best-effort   0              0                   -                  -                       diamanti.com/template=true
high          20k            500M                -                  -                       diamanti.com/template=true
medium        5k             125M                -                  -                       diamanti.com/template=true
```
Default 로 best-effort/medium/high 3가지 Type 제공 

Performance Tier 생성
- 예제 명령어 참고 가능

```
spkr@erdia22:~/02.k8s_code/14.secret$ dctl perf-tier create
Error: example usage -  dctl perf-tier create perf-tier1 -i 1k -b 1G -l type=backend
   storage IOPS should be in kilobytes
   Network bandwidth should be in gigabytes

spkr@erdia22:~/02.k8s_code/14.secret$ dctl perf-tier create large -i 1k -I 10K  -b 0.5G -B 2G
NAME      STORAGE IOPS   NETWORK BANDWIDTH   MAX STORAGE IOPS   MAX NETWORK BANDWIDTH   LABELS
large     1k             500M                10k                2G                      <none>
```
IOPS : Min 1k/Max 10k, Bandwidth : Min 500M/Max 2G 설정 

POD Performance Tier 적용
- YAML 파일 Annotations 항목 추가 

소스 코드 : [Perf Tier 적용](./perftier-pod.yml)

```
(...)
metadata:
  annotations:
    diamanti.com/endpoint0: '{"network":"blue","perfTier":"large"}'  # Perf tier 이름 적용
```

