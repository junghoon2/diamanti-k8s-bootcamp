#!/bin/bash

. $(dirname ${BASH_SOURCE})/util.sh

#run "dctl cluster create demo-cluster appserv76,appserv77,appserv78 --vip 172.16.20.251 --poddns demo.eng.diamanti.com --svlan 500 -p Test1234!"
run "dctl login -u admin -p Diamanti1!"
run "dctl cluster status"

run "echo 'dctl network list' & dctl network list"
# run "dctl network create blue -s 172.16.225.0/24 --start 172.16.225.203 --end 172.16.225.254  -g 172.16.225.1 -v 225"
# run "dctl network list"

# run "dctl volume list"
# run "dctl volume create test-1 -s 10G"
# run "dctl volume list"
# run "dctl volume delete test-1 -y"

run "dctl perf-tier list"
# run "dctl perf-tier create low -i 1k -b 10M"
# run "dctl perf-tier list"

$(dirname ${BASH_SOURCE})/create-iperf-fio.sh dia01 dia02 dia03 blue
run "kubectl get pods -o wide"

run "kubectl get pods -o wide"

run "dctl cluster status"

