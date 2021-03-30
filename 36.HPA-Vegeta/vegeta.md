초 당 2000번 실행하면 cpu 부하 증가
. 2000번 밑으로는 부하 증가하지 않음 

echo "GET https://vip.bizcubex.co.kr/gw/gw050A999?loginId=admin&password=111111&groupSeq=vip" | vegeta attack -name=1000qps -rate=1000 -duration=5m | tee results.1000qps.bin |vegeta report

spkr@erdia22:~$ echo "GET http://cafe.example.com/coffee" | vegeta attack -name=250qps -rate=250 -duration=360s | tee results.250qps.bin |vegeta report
^CRequests      [total, rate, throughput]         43336, 250.01, 250.00
Duration      [total, attack, wait]             2m53s, 2m53s, 2.987ms
Latencies     [min, mean, 50, 90, 95, 99, max]  1.909ms, 9.276ms, 4.769ms, 8.507ms, 27.521ms, 122.253ms, 322.671ms
Bytes In      [total, mean]                     6977096, 161.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:43336
Error Set:

spkr@erdia22:~$ echo "GET http://cafe.example.com/coffee" | vegeta attack -name=250qps -rate=2000 -duration=360s | tee results.250qps.bin |vegeta report

spkr@erdia22:~$ echo "GET http://cafe.example.com/coffee" | vegeta attack -name=250qps -rate=2000 -duration=360s | tee results.250qps.bin |vegeta report
^CRequests      [total, rate, throughput]         529888, 2000.01, 1994.06
Duration      [total, attack, wait]             4m25s, 4m25s, 2.966ms
Latencies     [min, mean, 50, 90, 95, 99, max]  53.8µs, 15.237ms, 4.481ms, 20.319ms, 38.664ms, 292.657ms, 3.076s
Bytes In      [total, mean]                     85059359, 160.52
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           99.70%
Status Codes  [code:count]                      0:1569  200:528319
Error Set:
Get "http://cafe.example.com/coffee": dial tcp 0.0.0.0:0->10.10.100.32:80: socket: too many open files


부하 40m 이상 증가하지 않음
Every 2.0s: kubectl top pod                                       erdia22: Fri Oct 30 10:27:06 2020

NAME                                    CPU(cores)   MEMORY(bytes)
coffee-97d6964d8-25z55                  39m          21Mi
coffee-97d6964d8-84j42                  38m          21Mi
coffee-97d6964d8-dg5kd                  47m          21Mi
coffee-97d6964d8-k6mfn                  44m          21Mi
coffee-97d6964d8-nb4ll                  39m          21Mi
coffee-97d6964d8-pjznd                  43m          21Mi
coffee-97d6964d8-tglvr                  40m          21Mi
coffee-97d6964d8-xm8f5                  33m          21Mi
ingress-nginx-ingress-79667d789-7v48t   357m         65Mi
tea-8bd958b5b-6tmmp                     0m           21Mi

8개까지 pod 증가
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/32.HPA$ k get hpa
NAME     REFERENCE           TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
coffee   Deployment/coffee   20%/20%   1         10        8          6m59s
tea      Deployment/tea      0%/50%    1         10        1          100m

