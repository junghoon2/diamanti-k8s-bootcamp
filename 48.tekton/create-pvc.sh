kubectl create configmap config-artifact-pvc \
                         --from-literal=size=10Gi \
                         --from-literal=storageClassName=openebs-hostpath \
                         -o yaml -n tekton-pipelines \
                         --dry-run=client | kubectl replace -f -