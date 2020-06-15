# Kubernetes Service
### Kubernetes 환경에서 서로 다른 POD 간 통신은 Service 사용
### POD는 항상 생성되고 사라질 수 있으므로 유동적으로 변할 수 있는 POD의 IP가 아닌 Domain 기준으로 상호 간 통신
### POD의 IP는 Service의 Domain Name으로 등록됨 

## 실습을 위한 Deploy POD 생성
- [NGINX POD 생성](https://github.com/junghoon2/diamanti-k8s-bootcamp/blob/master/02.Deploy/nginx.yml)
- [NGINX POD 생성](../../02.Deploy/nginxhello-deploy.yml)

