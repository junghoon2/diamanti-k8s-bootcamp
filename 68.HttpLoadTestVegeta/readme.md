Http 부하 테스트
. Ingress Controller 부하테스트를 위한 vegeta (Http load testing tool) 테스트 내역
. 초 당 connection 에 따라 부하 생성
. 테스트 결과를 그래프 형태로 변환 가능

참조 URL
. https://github.com/tsenart/vegeta

Vegeta is a versatile HTTP load testing tool built out of a need to drill HTTP services with a constant request rate. It can be used both as a command line utility and a library.

설치
. 실행 파일 PATH 영역에 Copy로 간단히 가능

테스트 내역
. 초 당 250, 500번 Request 요청 
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

실행 방법 참조 URL
. https://medium.com/@deepshig/starting-with-load-tests-e5e83ed539ac

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/44.HttpLoadTest$ vegeta attack -rate=100 -duration=5s -targets=targets.txt | vegeta report
Requests      [total, rate, throughput]         500, 100.20, 88.58
Duration      [total, attack, wait]             5.644s, 4.99s, 654.513ms
Latencies     [min, mean, 50, 90, 95, 99, max]  285.105ms, 1.009s, 941.441ms, 1.527s, 1.599s, 1.718s, 1.783s
Bytes In      [total, mean]                     92000, 184.00
Bytes Out     [total, mean]                     22500, 45.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:500
Error Set:

spkr@erdia22:~$ echo "POST http://erp10.douzone.com/api/CI/OrganizationStructureConfigurationCOPService/orgcop00400_list_header?USER_FG_CD=&search_text=&paging=true&pagingStart=1000&pagingCount=1000&_=1603700586721" | vegeta attack -header "x-authenticate-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Q29kZSI6IkdFUlAiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJzY29wZSI6WyJTVEdPUkEiXSwidXNlcmlkIjoieW1qOTM5MSIsImp0aSI6IjVmNTk2YzU2LThjODUtNDA0My05OGI4LWJmYjdiNjEyNjRiYyIsImNsaWVudF9pZCI6IlNUR09SQSIsImdyb3VwQ29kZSI6IjQwMDAifQ.B4ueCPV34iRwAQEj7qu7ni8Klws3c5g5NHGeqgQYcn8" -duration=5s -rate=10 |vegeta report
Requests      [total, rate, throughput]         50, 10.20, 10.04
Duration      [total, attack, wait]             4.982s, 4.9s, 81.841ms
Latencies     [min, mean, 50, 90, 95, 99, max]  67.306ms, 118.392ms, 90.106ms, 212.259ms, 234.753ms, 237.614ms, 237.614ms
Bytes In      [total, mean]                     5100, 102.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:50
Error Set:

spkr@erdia22:~$ echo "POST http://erp10.douzone.com/api/CI/OrganizationStructureConfigurationCOPService/orgcop00400_list_header?USER_FG_CD=&search_text=&paging=true&pagingStart=1000&pagingCount=1000&_=1603700586721" | vegeta attack -header "x-authenticate-token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJjb21wYW55Q29kZSI6IkdFUlAiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJzY29wZSI6WyJTVEdPUkEiXSwidXNlcmlkIjoieW1qOTM5MSIsImp0aSI6IjVmNTk2YzU2LThjODUtNDA0My05OGI4LWJmYjdiNjEyNjRiYyIsImNsaWVudF9pZCI6IlNUR09SQSIsImdyb3VwQ29kZSI6IjQwMDAifQ.B4ueCPV34iRwAQEj7qu7ni8Klws3c5g5NHGeqgQYcn8" -duration=5s -rate=100 |
vegeta report
Requests      [total, rate, throughput]         500, 100.20, 87.39
Duration      [total, attack, wait]             5.722s, 4.99s, 731.674ms
Latencies     [min, mean, 50, 90, 95, 99, max]  435.066ms, 902.021ms, 911.13ms, 1.056s, 1.111s, 1.24s, 1.277s
Bytes In      [total, mean]                     51000, 102.00
Bytes Out     [total, mean]                     0, 0.00
Success       [ratio]                           100.00%
Status Codes  [code:count]                      200:500
Error Set: