# felice 설치 heml chart
본 chart는 SPARK 배보폰 카프카 설치를 위한 helm 차트이다.

## 설치 전 준비 사항
### Kafka Cluster 구성
펠리체는 카프카 클러스터를 관리하기위한 도구이므로 먼저 카프카서비스를 반드시 준비해야 한다.

### values.yaml
다음을 참고하여 차트의 values.yml에 필요한 설정을 한다.
- image.registry
  이미지 레지스트리를 입력한다. 이미지 이름 바로 앞까지 경로를 입력한다.
- imagePullSecrets: []
  컨테이너 이미지를 가져올 때 credential이 필요하다면 `[]` 부분을 삭제하고 array 형태로 secret 이름을 입력한다.
- monitoringTargets
  모니터링 대상 클러스터의 구성 정보이다. Helm으로 구성한 ZooKeeper, Kafka의 releaseName을 정확하게 입력해야 한다. 기본적으로 서버를 찾는 방법은 `{{ zookeeper.releaseName }}-0.{{ zookeeper.releaseName }}-hs.{{ suffix }}` 형식으로 찾는다.
- storage
  - tsdb
    모니터링 메트릭 데이터를 저장할 tsdb 스토리지
  - rulesdir
    알람 룰을 저장할 스토리지
  - datadir
    내부 데이터베이스 데이터 보관 스토리지
- containerPorts
  pod 내부의 각 컨테이너 서비스 포트와 모니터링 포트를 설정한다. 변경할 일은 거의 없다.
- resources
  리소스 요청을 입력한다.

## 설치
다음의 예와 같은 명령으로 차트를 이용하여 펠리체 서비스를 설치할 수 있다.
```
helm install spark-felice ./
```

## 제거
다음의 예와 같은 명령으로 설치된 서비스를 제거할 수 있다.
```
helm delete spark-felice
```


