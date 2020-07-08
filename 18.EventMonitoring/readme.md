# Kubernetes Event Monitoring
- ### kubernetes 및 diamanti 관련 event는 dctl event 명령어로 조회

```
spkr@erdia22:~$ dctl event
NAME:
   dctl event - Event commands

USAGE:
   dctl event command [command options] [arguments...]

COMMANDS:
     list       List events
     status     Show policies for events
     configure  Configure policies for events

OPTIONS:
   --help, -h  show help
```

### Event view
```
spkr@erdia22:~$ dctl event list --help
NAME:
   dctl event list - List events

USAGE:
   dctl event list [command options] [arguments...]

DESCRIPTION:
   dctl event list

OPTIONS:
   --namespace value, --ns value  Filter by namespace
   --node value, -n value         Filter events associated with objects of kind "Node" by source node ip or "all" nodes
   --pod value, -p value          Filter by pod name or "all" pods
   --volume value, -v value       Filter by volume name or "all" volumes
   --source value, -s value       Filter by event source, eg: scheduler
   --severity value, --sev value  Filter by severity, eg: ERROR
   --limit value, -l value        Limit the number of events to display up to 1000 (default: 50)
   --offset value, -o value       Offset for the events (default: 0)

spkr@erdia22:~$ dctl event list
FIRST-SEEN   LAST-SEEN   COUNT     SEVERITY   NAMESPACE   NAME                                       UUID                                   KIND               HOST      COMPONENT           REASON      MESSAGE
59m          59m         1         INFO       default     centos7                                    bd1842a7-4524-4b7b-86ac-f5d6d945c428   Pod                          default-scheduler   Scheduled   Successfully assigned default/centos7 to dia02
(...)
```

Namespace 별 조회
```
spkr@erdia22:~$ dctl event list --ns test
FIRST-SEEN   LAST-SEEN   COUNT     SEVERITY   NAMESPACE   NAME                       UUID                                   KIND      HOST      COMPONENT   REASON    MESSAGE
17d          17d         1         INFO       test        mariadb-test-0             2f2eb290-ffa6-4604-ba8d-a4fea7bd85c2   Pod       dia01     convoy      Started   Started scheduling pod test/mariadb-test-0
17d          17d         1         INFO       test        mariadb-test-0             2f2eb290-ffa6-4604-ba8d-a4fea7bd85c2   Pod       dia01     convoy
      Success   Scheduled pod test/mariadb-test-0 on node "dia01"
8d           8d          1         INFO       test        mariadb-test-0             b8734e18-ea5b-4206-998f-9b2f2884bf8e   Pod       dia01     convoy      Started   Started scheduling pod test/mariadb-test-0
8d           8d          1         INFO       test        mariadb-test-0             b8734e18-ea5b-4206-998f-9b2f2884bf8e   Pod       dia01     convoy      Success   Scheduled pod test/mariadb-test-0 on node "dia01"
4d           4d          1         INFO       test        busybox-6c5b64fb4f-bzrj6   58f1f746-aaf8-4f34-a43c-6861e5a2895b   Pod       dia01     convoy      Started   Started scheduling pod test/busybox-6c5b64fb4f-bzrj6
(...)
```

심각도 별 조회
```
spkr@erdia22:~$ dctl event list -s ERROR
FIRST-SEEN   LAST-SEEN   COUNT     SEVERITY   NAMESPACE   NAME      UUID      KIND      HOST      COMPONENT   REASON    MESSAGE
spkr@erdia22:~$ dctl event list -s WARNING
FIRST-SEEN   LAST-SEEN   COUNT     SEVERITY   NAMESPACE   NAME      UUID      KIND      HOST      COMPONENT   REASON    MESSAGE
```

Event 설정
- SNMP 서버 및 보관 주기 설정 가능

```
spkr@erdia22:~$ dctl event configure
NAME:
   dctl event configure - Configure policies for events

USAGE:
   dctl event configure [command options] [arguments...]

DESCRIPTION:
   dctl event configure --retention-days 60 --snmp-enable=true --snmp-receiver=172.16.6.105,172.16.6.106

OPTIONS:
   --retention-days value  Period to retain events in days (default: 30)
   --snmp-enable           Enable SNMP traps (true or false)
   --snmp-community value  SNMP community string (default: "public")
   --snmp-receiver value   Comma separated list of SNMP receivers, required with --snmp-enable=true

spkr@erdia22:~$ dctl event status
Retention Days  : 30
SNMP Enable     : false
```

