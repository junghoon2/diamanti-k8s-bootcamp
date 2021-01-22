# kafka 설치 heml chart
본 chart는 SPARK 배보폰 카프카 설치를 위한 helm 차트이다.

## 설치 전 준비 사항
### ZooKeeper 서비스 설치
카프카는 주키퍼 서비스가 필요하므로 반드시 먼저 준비해야 한다.

### values.yaml
다음을 참고하여 차트의 values.yml에 필요한 설정을 한다.
- replicaCount
  설치할 카프카 브로커 노드 수를 입력한다.
- image.registry
  이미지 레지스트리를 입력한다. 이미지 이름 바로 앞까지 경로를 입력한다.
- image.imagename
  이미지 이름을 입력한다. SPARK 배포본은 kafka-docker 이다.
- imagePullSecrets: []
  컨테이너 이미지를 가져올 때 credential이 필요하다면 `[]` 부분을 삭제하고 array 형태로 secret 이름을 입력한다.
- env
  - KAFKA_ZOOKEEPER_CONNECT : 카프카가 연결할 ZooKeeper 서버.
    spark-zookeeper helm chart로 구축한 경우에는 cluster 서비스로 지정해도 된다.
  - JMX_PROMETHEUS_ENABLE : 모니터링을 위한 exporter 활성화
  - JMX_PROMETHEUS_PORT : 모니터링 포트 (기본 값은 9404)
- storage
  퍼시스턴트 볼륨 크기
- resources
  리소스 요청을 입력한다.

## 설치
다음의 예와 같은 명령으로 차트를 이용하여 카프카 서비스를 설치할 수 있다.
```
helm install spark-kafka ./
```

## 제거
다음의 예와 같은 명령으로 설치된 서비스를 제거할 수 있다.
```
helm delete spark-kafka
```
