#!/bin/bash

# .KUBECONFIG에 여러 콘텍스트가 있을 수 있으므로, 가능한 모든 클러스터를 확인한다.
#kubectl config view -o jsonpath='{"Cluster name\tServer\n"}{range .clusters[*]}{.name}{"\t"}{.cluster.server}{"\n"}{end}'

# 위의 출력에서 상호 작용하려는 클러스터의 이름을 선택한다.
export CLUSTER_NAME="hci2-cloud1-dz"

# 클러스터 이름을 참조하는 API 서버를 가리킨다.
APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"$CLUSTER_NAME\")].cluster.server}")

# 토큰 값을 얻는다
TOKEN=$(kubectl get secrets -o jsonpath="{.items[?(@.metadata.annotations['kubernetes\.io/service-account\.name']=='default')].data.token}"|base64 --decode)

# TOKEN으로 API 탐색
curl -X GET $APISERVER/apis/apps/v1/namespaces/tomcat-stage01/deployments/tomcat-webauthn/status --header "Authorization: Bearer $TOKEN" --insecure
