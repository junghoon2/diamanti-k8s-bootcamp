vegeta attack -rate=100 -duration=5s -targets=targets.txt | vegeta report

echo "GET http://172.17.30.171/" | vegeta attack -name=250qps -rate=250 -duration=5s | tee results.250qps.bin |vegeta report

spkr@erdia22:~/15.loadTest/vegeta_12.8.4_linux_amd64$ echo "GET http://10.10.120.14/" | vegeta attack -name=250qps -rate=250 -duration=5s | tee results.250qps.bin |vegeta report

Requests      [total, rate, throughput]         1250, 250.21, 249.89
Duration      [total, attack, wait]             5.002s, 4.996s, 6.517ms
Latencies     [min, mean, 50, 90, 95, 99, max]  3.189ms, 6.155ms, 5.747ms, 7.701ms, 8.577ms, 18.624ms, 43.835ms
Bytes In      [total, mean]                     765000, 612.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:1250
Error Set:

