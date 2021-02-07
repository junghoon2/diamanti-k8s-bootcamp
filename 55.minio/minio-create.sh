   kubectl minio tenant create minio-tenant-1 \
      --servers 3                             \
      --volumes 3                            \
      --capacity 100Ti                         \
      --namespace minio-tenant-1              \
      --storage-class local-storage        \
