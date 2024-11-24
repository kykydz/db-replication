#!/bin/bash

docker cp master-config.cnf db_master_svc:etc/my.cnf && docker cp replica-config.cnf db_replica_svc:etc/my.cnf

# check config and make sure server-id, log-bin, binlog-do-db
# docker exec -it mysql_primary cat /etc/my.cnf
# docker exec -it mysql_secondary cat /etc/my.cnf

docker restart db_master_svc db_replica_svc

# check master status, for: getting which log filename and position
docker exec -it db_master_svc mysql -uroot -ppass123 -e "SHOW MASTER STATUS;"

docker exec -it db_master_svc mysql -uroot -ppass123 -e "GRANT REPLICATION SLAVE ON *.* TO 'piuw_dev'@'%'; FLUSH PRIVILEGES;"

# Change replica to point to the primary mysql server
docker exec -it db_replica_svc mysql -uroot -ppass123 -e "CHANGE MASTER TO MASTER_HOST='db_network_master', MASTER_PORT=3306, MASTER_USER='piuw_dev', MASTER_PASSWORD='zxcv123', MASTER_LOG_FILE='mysql-bin.000001', MASTER_LOG_POS=548, MASTER_CONNECT_RETRY=60, GET_MASTER_PUBLIC_KEY=1;"
# docker exec -it db_replica_svc mysql -uroot -ppass123 -e "CHANGE MASTER TO MASTER_HOST='db_primary', MASTER_PORT=3306, MASTER_USER='piuw_dev', MASTER_PASSWORD='zxcv123', MASTER_LOG_FILE='mysql-bin.000004', MASTER_LOG_POS=157, MASTER_CONNECT_RETRY=60, GET_MASTER_PUBLIC_KEY=1;"

docker exec -it db_replica_svc mysql -uroot -ppass123 -e "START REPLICA;"

# Verify the replication status
# docker exec -it db_replica_svc mysql -uroot -ppass123 -e "SHOW SLAVE STATUS\G"
