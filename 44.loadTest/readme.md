Ingress Controller 부하테스트를 위한 vegeta, Http load testing tool 테스트 내역 공유해 드립니다. 향후 ingress controller 부하 테스트 시 적용하면 될 것 같습니다.

(ERP 팀에서 유사한 요청 사항이 있어서 검색하다 찾았습니다.)


초 당 connection 숫자 변화에 따라 응답 시간 결과를 그래프 형태로 변환 가능한 Tool 입니다. 


https://github.com/tsenart/vegeta

Vegeta is a versatile HTTP load testing tool built out of a need to drill HTTP services with a constant request rate. It can be used both as a command line utility and a library.

spkr@erdia22:~/15.loadTest/vegeta_12.8.4_linux_amd64$ echo "GET http://10.10.120.14/" | vegeta attack -name=250qps -rate=250 -duration=5s | tee results.250qps.bin |vegeta report

Requests      [total, rate, throughput]         1250, 250.21, 249.89
Duration      [total, attack, wait]             5.002s, 4.996s, 6.517ms
Latencies     [min, mean, 50, 90, 95, 99, max]  3.189ms, 6.155ms, 5.747ms, 7.701ms, 8.577ms, 18.624ms, 43.835ms
Bytes In      [total, mean]                     765000, 612.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:1250
Error Set:


spkr@erdia22:~/15.loadTest/vegeta_12.8.4_linux_amd64$ vegeta plot results.250qps.bin  > plot250qps.html
spkr@erdia22:~/15.loadTest/vegeta_12.8.4_linux_amd64$ echo "GET http://10.10.120.14/" | vegeta attack -name=500qps -rate=500 -duration=5s | tee results.500qps.bin |vegeta report
Requests      [total, rate, throughput]         2500, 500.26, 499.31
Duration      [total, attack, wait]             5.007s, 4.997s, 9.456ms
Latencies     [min, mean, 50, 90, 95, 99, max]  3.649ms, 6.769ms, 6.52ms, 8.256ms, 8.616ms, 10.265ms, 15.396ms
Bytes In      [total, mean]                     1530000, 612.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:2500
Error Set:

