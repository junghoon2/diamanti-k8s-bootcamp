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
fio wrtie.fio --output /data/fio-write.out
```
