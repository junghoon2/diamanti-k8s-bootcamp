# Installing and Configuring Prometheus using prometheus-operator


## Table of contents
  * [About repository](#about-repository)
  * [The Prometheus Operator](#the-prometheus-operator)
  * [High Availability](#high-availability)
  * [Pre-requisites](#pre-requisites)
  * [Installation Procedure](#installation-procedure)
    + [Helm repository](#helm-repository)
    + [Ingress](#ingress)
      - [Pre-requisites](#pre-requisites-1)
      - [Configuring the ingress](#configuring-the-ingress)
        * [Example configuration](#example-configuration)
    + [Preparing values file](#preparing-values-file)
    + [Installating charts](#installating-charts)
    + [Creating the Prometheus Service Monitors](#creating-the-prometheus-service-monitors)
    + [Creating the alert manager configuration](#creating-the-alert-manager-configuration)
  * [Accessing Prometheus and Grafana UI](#accessing-prometheus-and-grafana-ui)  
  * [Diamanti metrics](#diamanti-metrics)


## About repository

This repository collects Kubernetes manifests, Grafana dashboards, Service Monitors and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the **Prometheus Operator**.
This repository uses kube-prometheus-stack helm charts from https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
> **Note:** The installation procedure assumes the data metrices are already exported by some exporter.

## The Prometheus Operator
The Prometheus Operator is simple to install with a single command line, and enables users to configure and manage instances of Prometheus using simple declarative configuration that will, in response, create, configure and manage Prometheus monitoring instances.
For an example refer https://coreos.com/blog/the-prometheus-operator.html

## High Availability

For production ready Grafana, AlertManager and Prometheus should run 3 replicas.
Prometheus storage class should be configured for 3-way mirror for highest efficiency and availability.

> **NOTE** Change the replicas count to 3 in values.yaml file at time of installation.

## Pre-requisites
- A functioning Diamanti cluster with all diamanti-system pods in Running state.
```  
dctl -s VIP login
kubectl get pods -n diamanti-system
```

- helm already installed

## Installation Procedure

Installation of prometheus, grafana and alert manager include following steps :-
  - Adding the helm repository
  - Preparing the values.yaml file as per requirements
  - Installing the charts
  - Creating the Prometheus Service Monitors
  - Creating the alert manager configuration.
  - Creating the grafana dashboards.

### Helm repository

If cluster is non-airgapped add the following repository
```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
```
> In case of airgapped cluster use the charts provided in the charts folder and skip this step.


### Ingress

#### Pre-requisites
  - Ingress controller should be installed and running.

#### Configuring the ingress

To install ingress for grafana, prometheus and alert manager configure following values in values.yaml in grafana, Prometheus and alert section respectively 

| Parameter | Values     |
| :---      |    :----   |
| ingress.enabled | true |
| ingress.annotations | set the annotations as per controller. For e.g for nginx controller kubernetes.io/ingress.class: nginx |
| ingress.hosts | hostname For e.g grafana.example.com |

##### Example configuration
```
  ingress:
    ## If true, Grafana Ingress will be created
    ##
    enabled: true

    ## Annotations for Grafana Ingress
    ##
    annotations:
       kubernetes.io/ingress.class: spektra-system

    ## Labels to be added to the Ingress
    ##
    labels: {}

    ## Hostnames.
    ## Must be provided if Ingress is enable.
    ##
    # hosts:
    #   - grafana.domain.com
    hosts:
      - grafana.example.com
    ## Path for grafana ingress
    path: /

    ## TLS configuration for grafana Ingress
    ## Secret must be manually created in the namespace
    ##
    tls: []
    # - secretName: grafana-general-tls
    #   hosts:
    #   - grafana.example.com
```
```
kubectl get ingress -n rbc
NAME                          CLASS    HOSTS                 ADDRESS         PORTS   AGE
prometheus-operator-grafana   <none>   grafana.example.com   172.16.220.24   80      37m
```


### Preparing values file

values.yaml file in chart folder is pre configured to install prometheus operator, grafana and alert manager.
Prometheus is installed with 100Gi storage and retention period of 10 days.

Alert manager configuration can be provided at installation time or it can be configured later.
Refer alermanager:config section in values.yaml file.

### Installating charts

The following will install the charts
```
For helm version 3
helm install <name> -n <namespace> --create-namespace -f <path to values.yaml> <chart name>
for e.g
helm install prometheus-operator -n rbc --create-namespace -f values.yaml prometheus-community/kube-prometheus-stack

For helm version 2
helm install <chart name> -n <name> --namespace <namespace> -f <path to values.yaml> 
for e.g

helm install prometheus-community/kube-prometheus-stack -n prometheus-operator --namespace rbc -f values.yaml
```
> Make sure chart is deployed and pods are in running state.

In case of airgapped cluster use the local chart.

### Creating the Prometheus Service Monitors

Refer for details on service monitors https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/user-guides/getting-started.md

```
First create the cadvisor service

- kubectl apply -f cadvisor_service.yaml

Then create the service monitors by executing below command

- kubectl apply -f servicemonitor.yaml -n <namespace>
```
Make sure service monitor are created succesfully
>kubectl get servicemonitors.monitoring.coreos.com  -n \<namespace\>

### Creating the alert manager configuration

Rules created in prometheus will send alerts to alermanager and alertmanager can be configured to send alerts via email or slack.

User can provide the alert manager configuration either at time of chart installation or after installation is over.

- At time of chart installation, sample configuration in values.yaml file

  ```
     config:
       global:
         resolve_timeout: 5m
       route:
         group_by: ['job']
         group_wait: 30s
         group_interval: 5m
         repeat_interval: 12h
         receiver: 'email'
       receivers:
       - name: 'email'
         email_configs:
         - to: user@gmail.com
           from: corporateuser@gmail.com
           smarthost: smtp.gmail.com:587
           auth_username: "corporateuser@gmail.com"
           auth_identity: "corporateuser@gmail.com"
           auth_password: "auth_password"
```   

- Configuring alert manager after installation
 - Delete the alert manager secret
   ``` kubectl delete secret alertmanager-prometheus-operator-kube-p-alertmanager -n <namespace> ```
  
 - Refer alertmanager.yaml file in repo and create the configuration.
 
 - Create secret <code> kubectl create  secret generic alertmanager-prometheus-operator-kube-p-alertmanager --from-file=alertmanager.yaml -n \<namespace\> </code>


> For details refer https://prometheus.io/docs/alerting/latest/configuration/

### Creating the grafana dashboards

To create the grafana dashboards
``` kubectl apply -f grafana_dashboard.yaml -n <namespace> ```

> **NOTE** Grafana admin user password is defined in values.yaml

## Creating Prometheus Alert Rules

Refer "https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/"

To create the rule using monitoring resources refer the sample alert configuration.

```
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  annotations:
    meta.helm.sh/release-name: prometheus-operator
  labels:
    app: kube-prometheus-stack
    app.kubernetes.io/managed-by: Helm
    chart: kube-prometheus-stack-10.1.0
    heritage: Helm
    release: prometheus-operator
  name: prometheus-operator-cpu.rules
spec:
  groups:
  - name: cpu-rule
    rules:
    - alert: cpuUsagehigh
      expr: sum(collectd_cpu_percent) > 1
      for: 1m
      labels:
        severity: warning
      annotations:
        summary: "collectd high cpu usage"


```
``` kubectl apply -f <rule_file.yaml> -n namespace ```

To view the rules ``` kubectl get prometheusrules.monitoring.coreos.com -n <namespace> ```

## Accessing Prometheus and Grafana UI

To access the prometheus UI first get the prometheus pod IP
``` 
kubectl get pods -n <namespace> -o wide 

For e.g
diamanti@solserv11:~/mudit/prometheus$ kubectl get pods -n rbc -o wide
NAME                                                     READY   STATUS    RESTARTS   AGE    IP              NODE        NOMINATED NODE   READINESS GATES
alertmanager-prometheus-operator-kube-p-alertmanager-0   2/2     Running   0          3h2m   172.16.209.88   solserv11   <none>           <none>
prometheus-operator-grafana-86cbc8bf89-sgj6t             2/2     Running   0          3h2m   172.16.209.87   solserv11   <none>           <none>
prometheus-operator-kube-p-operator-6fbdd47657-dcl6j     2/2     Running   0          3h2m   172.16.209.86   solserv11   <none>           <none>
prometheus-prometheus-operator-kube-p-prometheus-0       3/3     Running   1          3h1m   172.16.209.85   solserv11   <none>           <none>

Access Prometheus UI 172.16.209.85:9090
Access Grafana UI 172.16.209.87:3000
```
> Prometheus listen on port 9090 and Grafana on 3000
 >
>In case ingress is configured use the corresponding hostname and port number should be used. For e.g grafana.example.com:5080

## Diamanti metrics
If you want to create alerts based on the data similar to what you see on Diamanti GUI, you need to use Diamanti metrics.


On every node, as part of collectd exporter, Diamanti runs a plugin to trigger every 10 seconds a python script processing metrics.  Node exporter used to expose all generated custom metrics.

Those metrics used by the GUI and available:
```
  • diamanti_container_cpu_load_average_10s 
  • diamanti_container_memory_usage_bytes
  • diamanti_node_blocks_read
  • diamanti_node_blocks_read_usec
  • diamanti_node_blocks_write
  • diamanti_node_blocks_write_usec
  • diamanti_pod_bytes_rx
  • diamanti_pod_bytes_tx
  • diamanti_volume_blocks_read
  • diamanti_volume_blocks_written
  • collectd_df_df_complex
  • collectd_memory
  • collectd_cpu_percent
```
Volume blocks and network pod level metrics are incremental (counters), so we use derivatives on them. 

So, for IOPS calculations we use derivative calculation based on volume blocks (read and written), and for network data we use derivative calculation based on network counters for read or write. 

For read and write pod latency we use calculation based on averaged over the last 30 sec data from diamanti_node_blocks_read_usec or diamanti_node_blocks_write_usec divided by averaged over the last 30 sec data from diamanti_node_blocks_read or diamanti_node_blocks_written.

Following is a table of all used by the GUI parameters with corresponding prometheus queries:

| Parameter | Prometheus query |
| :---      |    :----         |
| cpu usage for container C | 1000 * sum (rate (diamanti_container_cpu_load_average_10s{}[1m])) by (pod_name,container_name,namespace) |
| cpu usage for container C over time (graph data) | (deriv(diamanti_container_cpu_load_average_10s{container_name=‘CONTAINER_NAME’,pod_name=‘POD_NAME’,namespace=‘NAMESPACE’}[interval]) * nanoCoresPerCore)[interval:step],where nanoCoresPerCore=1000000000; step=10s; interval=1h/6h/12h; CONTAINER_NAME,POD_NAME,NAMESPACE for a single pod |
| pod memory usage for container C | avg_over_time(diamanti_container_memory_usage_bytes{container_name=‘CONTAINER_NAME’,pod_name=‘POD_NAME’;namespace=‘NAMESPACE’}[10s]) |
| pod memory usage for container C over time (graph data) | diamanti_container_memory_usage_bytes{container_name=‘CONTAINER_NAME’,pod_name=‘POD_NAME’;namespace=‘NAMESPACE’}[interval], where interval=1h/6h/12h; CONTAINER_NAME,POD_NAME,NAMESPACE for a single pod |
| pod storage usage | collectd_df_df_complex{type=‘used’,df=~’DEVICE_NAME',exported_instance='HOST'}[interval], where DEVICE_NAME=nvme device name; HOST=host name; interval=1m/1h/6h/12h |
| pod network TX | deriv(diamanti_pod_bytes_tx{intf_name=‘INTERFACE_NAME’,source=‘HOST_NAME’,pod_name=‘POD_NAME’,namespace=‘NAMESPACE’}[interval]), where INTERFACE_NAME,POD_NAME,NAMESPACE for a single pod; HOST=host name; interval=1m/1h/6h/12h |
| pod network RX | deriv(diamanti_pod_bytes_rx{intf_name=‘INTERFACE_NAME’,source=‘HOST_NAME’,pod_name=‘POD_NAME’,namespace=‘NAMESPACE’}[interval]), where INTERFACE_NAME,POD_NAME,NAMESPACE for a single pod; HOST=host name; interval=1m/1h/6h/12h |
| pod IOPS read | deriv(diamanti_volume_blocks_read{source=‘HOST’,volume=’VOLUME’}[interval]), where HOST=host name; VOLUME=volume name; interval=1m/1h/6h/12h for each volume in the pod then aggregated |
| pod IOPS write | deriv(diamanti_volume_blocks_written{source=‘HOST’,volume=’VOLUME’}[interval]), where HOST=host name; VOLUME=volume name; interval=1m/1h/6h/12h for each volume in the pod then aggregated |
| node network RX | deriv(diamanti_pod_bytes_rx{source=‘HOST_NAME’}[interval]), where HOST=host name; interval=1m/1h/6h/12h |
| node network TX | deriv(diamanti_pod_bytes_tx{source=‘HOST_NAME’}[interval]), where HOST=host name; interval=1m/1h/6h/12h |
| node IOPS read | deriv(diamanti_volume_blocks_read{source=‘HOST’}[interval]), where HOST=host name; interval=1m/1h/6h/12h  |
| node IOPS written | deriv(diamanti_volume_blocks_written{source=‘HOST’}[interval]), where HOST=host name; interval=1m/1h/6h/12h  |
| volumes IOPS read | deriv(diamanti_volume_blocks_read{source=‘HOST’,volume=’VOLUME’}[interval]), where HOST=host name; VOLUME=volume name; interval=1m/1h/6h/12h  |
| volumes IOPS written | deriv(diamanti_volume_blocks_written{source=‘HOST’,volume=’VOLUME’}[interval]), where HOST=host name; VOLUME=volume name; interval=1m/1h/6h/12h  |
| nodes CPU usage | collectd_cpu_percent{cpu=‘active’,exported_instance=‘HOST'}[interval], where HOST=host name; interval=1m/1h/6h/12h  |
| nodes memory usage | collectd_memory{memory=‘free’,exported_instance=‘HOST'}[interval], where HOST=host name; interval=1m/1h/6h/12h  |
| nodes storage | collectd_df_df_complex{type=‘used’,df=~’DEVICE_NAME',exported_instance='HOST'}[interval], where DEVICE_NAME=nvme device name; HOST=host name; interval=1m/1h/6h/12h aggregated per host |

> **NOTE** The above prometheus installation will also add cadvisor as target. Diamanti club the cadvisor data to collectd.



