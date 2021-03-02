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


# run "echo 'dctl network list' & dctl network list"
# # run "dctl network create blue -s 172.16.225.0/24 --start 172.16.225.203 --end 172.16.225.254  -g 172.16.225.1 -v 225"
# # run "dctl network list"

# # run "dctl volume list"
# # run "dctl volume create test-1 -s 10G"
# # run "dctl volume list"
# # run "dctl volume delete test-1 -y"

# run "dctl perf-tier list"
# # run "dctl perf-tier create low -i 1k -b 10M"
# # run "dctl perf-tier list"

# $(dirname ${BASH_SOURCE})/create-iperf-fio.sh dia01 dia02 dia03 blue
# run "kubectl get pods -o wide"

# run "kubectl get pods -o wide"

# run "dctl cluster status"

