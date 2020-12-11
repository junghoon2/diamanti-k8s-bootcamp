
spkr@erdia22:~$ for i in $(dctl volume list|grep Available|cut -d " " -f 1); do dctl volume delete -y $i; done
Successfully accepted volume pvc-056c0d98-2c57-4924-b5b4-c0672d551804 delete request
Error from server: Multioperation transaction failed for txn map[/dw/storage/volumes/default/0ce59008-2eec-11eb-a786-a4bf014f8b47:0xc005131890 /dw/storage/volumes/pvc-062f16d2-e0c2-4605-bb19-381de5306a62:0xc005130fc0]
Successfully accepted volume pvc-0fa7baf5-1bd8-41c1-a4e2-662b246a609c delete request
Successfully accepted volume pvc-1110848b-dd26-468c-a646-7adf8b8cf1e7 delete request
Successfully accepted volume pvc-1892661c-7464-4e62-a153-0dd85b66ec55 delete request

`, ` 에러.. 
spkr@erdia22:~/12.Privatek8sCode/11.PJT/01.DZBizCubeX/04.elastic$ dctl volume delete `dctl volume list|grep Available|cut -d " " -f 1`
Error: example usage -  dctl volume delete vol1