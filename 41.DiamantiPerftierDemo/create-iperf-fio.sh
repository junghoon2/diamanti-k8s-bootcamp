#!/bin/bash

create_pods() {
	node=$1
	dest=$2
        net=$3
        qos=$4
        op=$5
	per_type=$6
        num=0

        case $qos in
            high) num=3 ;;
            medium) num=3 ;;
            best-effort) num=3;;
        esac
	for i in `seq 1 $num`
	do
              dctl volume create vol-$node-$qos-$i -s 10G --sel kubernetes.io/hostname=$node
	      sed -e 's/NET/'$net'/g' -e 's/NODE/'$node'/g' -e 's/QOS/'$qos'/g' -e 's/INDEX/'$i'/g' -e 's/DEST/'$dest'/g' -e 's/OP_TYPE/'$op'/g' -e 's/PER_TYPE/'$per_type'/g' iperf-fio.json | kubectl create -f -
	done
}

create_pods_with_qos() {
    for qos in best-effort medium high
    do
       create_pods $1 $2 $3 $qos $4 $5
    done
}

create_pods_with_qos $1 $2 $4 randrw 100
create_pods_with_qos $2 $3 $4 randrw 70
create_pods_with_qos $3 $1 $4 randrw 0
