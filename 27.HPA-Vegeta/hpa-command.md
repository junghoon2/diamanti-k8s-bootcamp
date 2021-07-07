kubectl autoscale deployment php-apache --cpu-percent=50 --min=1 --max=10

k get hpa 

kubectl run -it --rm load-generator --image=busybox /bin/sh

Hit enter for command prompt

while true; do wget -q -O- http://php-apache; done

k get hpa

1분 후 deploy 증가 확인 가능

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp/32.HPA$ kubectl run -it --rm load-generator --image=busybox /bin/sh
kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use kubectl run --generator=run-pod/v1 or kubectl create instead.

If you don't see a command prompt, try pressing enter.

# while true; do wget -q -O- http://php-apache; done
OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!OK!O

spkr@erdia22:~$ k get hpa
NAME         REFERENCE               TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   250%/50%   1         10        4          2m30s

spkr@erdia22:~$ k get deploy php-apache
NAME         READY   UP-TO-DATE   AVAILABLE   AGE
php-apache   5/5     5            5           2m54s

6개 이상 증가하지 않는다. 

spkr@erdia22:~$ k get hpa
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   57%/50%   1         10        6          3m52s

spkr@erdia22:~$ k get hpa
NAME         REFERENCE               TARGETS   MINPODS   MAXPODS   REPLICAS   AGE
php-apache   Deployment/php-apache   49%/50%   1         10        6          5m8s

