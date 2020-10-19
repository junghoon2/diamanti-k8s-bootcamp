kubectl delete rc --all
sleep 10
for svc in `kubectl get svc | grep -v kube | grep ip- | cut -d " " -f1`; do kubectl delete svc $svc; done
sleep 10
for vol in `dctl volume list | grep vol- | cut -d " " -f1`; do dctl volume delete $vol -y ; done
