   kubectl minio tenant create --name tenant-1 \
      --servers 3                             \
      --volumes 6                            \
      --capacity 60Gi                         \
      --namespace minio              \
      --storage-class openebs-hostpath        \
