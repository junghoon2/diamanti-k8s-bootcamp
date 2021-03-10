#!/bin/bash

# 5분 정도 소요 

dctl login -u admin -p Diamanti1!
read enter

echo "dctl cluster status"
dctl cluster status
read enter

echo "kubectl create namespace demo"
echo "dctl namespace set demo"
kubectl create namespace demo
sleep 1
kubectl get namespace

read enter
dctl namespace set demo
read enter

echo "dctl network list"
dctl network list
read enter

echo "dctl perf-tier list"
dctl perf-tier list
read enter

echo "Performance test using fio & iperf, create 3ea POD each 3ea perf tier for 3 nodes"
$(dirname ${BASH_SOURCE})/create-iperf-fio.sh dia01 dia02 dia03 blue
read enter

sleep 3
kubectl get pods -o wide

read enter
kubectl get pods -o wide

sleep 3
dctl cluster status

echo "See the Diamanti Admin Pages"

