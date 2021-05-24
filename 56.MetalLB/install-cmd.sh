# 최신 버전으로 설치 할 것
# kube-proxy CM 변경, ipvs to strictARP: true 변경 

## kube-proxy CM 변경 후 rollout restart 한다.  
kubectl rollout restart -n kube-system daemonset kube-proxy

# Diamanti 해당 없음

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.6/manifests/metallb.yaml

# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"

