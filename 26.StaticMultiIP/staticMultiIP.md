spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ dctl endpoint create --help
NAME:
   dctl endpoint create - Create an endpoint

USAGE:
   dctl endpoint create [command options] [arguments...]

DESCRIPTION:
   dctl endpoint create ep1 -n blue -ns default

OPTIONS:
   --ip value, -i value           IP address
   --network value, -n value      Name of the network
   --labels value, -l value       Labels for the endpoint
   --namespace value, --ns value  Namespace for the endpoint (default: "default")

spkr@erdia22:~/02.k8s/diamanti-k8s-bootcamp$ dctl endpoint create ep1 -n web --ip 10.10.120.91 --ns default
NAME      NAMESPACE   CONTAINER   NETWORK   IP                MAC       GATEWAY       VLAN      VF        PORT      NODE      LABELS
ep1       default                 web       10.10.120.91/24             10.10.120.1   120                                     <none>
```

### POD IP 지정

```
apiVersion: v1
kind: Pod
metadata:
  annotations:
    diamanti.com/endpoint0: '{"endpointId":"ep1","perfTier":"high"}'
  name: nginx
spec:
  containers:
  - name: nginx-pod
    image: nginx
