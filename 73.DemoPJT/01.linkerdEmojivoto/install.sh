# /bin/bash
# linkerd에서 제공하는 emojivoto App 

curl -sL https://run.linkerd.io/emojivoto.yml \
  | kubectl apply -f -

# 결과 
[spkr@erdia22 73.DemoPJT (ubuns:emojivoto)]$ kgp
NAME                        READY   STATUS    RESTARTS   AGE     IP               NODE       NOMINATED NODE   READINESS GATES
emoji-66ccdb4d86-4txt2      1/1     Running   0          3m16s   10.233.104.218   ubun20-1   <none>           <none>
vote-bot-69754c864f-lgxnf   1/1     Running   0          3m16s   10.233.66.170    ubun20-2   <none>           <none>
voting-f999bd4d7-8cwlf      1/1     Running   0          3m16s   10.233.66.171    ubun20-2   <none>           <none>
web-79469b946f-pq5nt        1/1     Running   0          3m16s   10.233.66.172    ubun20-2   <none>           <none>
