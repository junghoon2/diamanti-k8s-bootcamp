### centos7 pod 실행 후 추가 fio 설치
```
[spkr@erdia22 04.dz (dzb01:default)]$ k exec -it centos7 -- bash
[root@centos7 /]# yum -y install fio
Loaded plugins: fastestmirror, ovl
```

### fio script file 생성 
```
vi randread.fio
```

### fio 실행
```
[root@centos7 /]# fio randread.fio --output /data/fio-randread.out
Jobs: 16 (f=16): [r(16)][6.6%][r=96.6MiB/s,w=0KiB/s][r=24.7k,w=0 IOPS][eta 00m:57s]```
```
