### openebs 기본 디렉토리 변경
default 설정 시 파일 시스템 full 발생 할 수 있음 

### Install light version
If you would like to use only Local PV (hostpath and device), you can install a lite version of OpenEBS using the following command.
kubectl apply -f https://openebs.github.io/charts/openebs-operator-lite.yaml
kubectl apply -f https://openebs.github.io/charts/openebs-lite-sc.yaml

