# Kubernetes Cronjob
- ### Linux Cronjob과 동일하게 지정된 시간에 POD 실행하여 해당 작업 수행 시 사용 

### Cronjob
```
vi cronjob.yml

(...)
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: hello
spec:
  schedule: "*/2 * * * *"  
  jobTemplate:
```

Linux Cronjob과 동일한 작업 시간 형식
(* * * * * 분 시간 날짜 월 요일)

```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc apply -f cronjob.yml
cronjob.batch/hello created

해당 Cronjob 작업 수행 내역 확인 

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc get cronjobs.batch
NAME    SCHEDULE      SUSPEND   ACTIVE   LAST SCHEDULE   AGE
hello   */2 * * * *   False     0        79s             3m51s

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc get job
NAME               COMPLETIONS   DURATION   AGE
hello-1594269840   1/1           15s        3m38s
hello-1594269960   1/1           13s        98s
pi                 14/20         17m        17m
```
Cron 작업 삭제
```
spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/27.Cronjobs$ kc delete cronjobs.batch hello
cronjob.batch "hello" deleted
```
