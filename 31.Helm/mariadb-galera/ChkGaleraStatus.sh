show status like 'wsrep_%';
SHOW GLOBAL STATUS WHERE Variable_name IN('wsrep_ready', ' wsrep_cluster_size', 'wsrep_cluster_status' , ' wsrep_connected' ) ;
