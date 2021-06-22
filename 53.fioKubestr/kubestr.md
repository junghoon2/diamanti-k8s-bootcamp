kubestr fio -f fio-rand-read-Diamanti.fio -s high

[spkr@erdia22 66.fio-kubernetes (spkcluster:default)]$ kubestr fio -f fio-compression.fio -s high
PVC created kubestr-fio-pvc-px7p9
Pod created kubestr-fio-pod-wb4z5
Running FIO test (fio-compression.fio) on StorageClass (high) with a PVC of Size (100Gi)
Elapsed time- 2m6.6418608s
FIO test results:
  
FIO version - fio-3.20
Global options - ioengine= verify= direct= gtod_reduce=

JobName: 
  blocksize=4k filesize=1g iodepth=32 rw=randwrite
write:
  IOPS=377553.281250 BW(KiB/s)=1510221
  iops: min=249082 max=535406 avg=378120.718750
  bw(KiB/s): min=996328 max=2141624 avg=1512483.125000

Disk stats (read/write):
  nvme5n1: ios=0/46436180 merge=0/2240 ticks=0/6297641 in_queue=6566395, util=100.000000%
  -  OK