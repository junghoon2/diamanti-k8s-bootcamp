# bucket 이름 기존 생성한 bucket 이름 사용
# region 이름, 초기 minio 생성 시 지정
# url service 이름 대신 LoadBalancer ip 지정

velero install \
    --provider aws \
    --plugins velero/velero-plugin-for-aws:v1.0.0 \
    --bucket velero \
    --secret-file ./credentials-velero \
    --use-volume-snapshots=false \
    --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://172.17.29.112:9000 
