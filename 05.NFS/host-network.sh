spkr@erdia22:~$ dctl network create host-network -s 172.16.122.0/24 --start 172.16.122.200 --end 172.16.122.220 --host-network -g 172.16.122.1 -v 1022
NAME           TYPE      START ADDRESS    TOTAL     USED      GATEWAY        VLAN      NETWORK-GROUP   ZONE      PORT-GROUP
host-network   public    172.16.122.200   21        0         172.16.122.1   1022                                data