#!/bin/bash

docker cp master-config.cnf mysql_primary:etc/my.cnf && docker cp slave-config.cnf mysql_secondary:etc/my.cnf

# docker exec -it mysql_primary cat /etc/my.cnf
# docker exec -it mysql_secondary cat /etc/my.cnf

docker restart mysql_primary mysql_secondary
# docker restart mysql_secondary

# check master status, for: getting which log filename and position
# docker exec -it mysql_primary mysql -uroot -ppass123 -e "SHOW MASTER STATUS;"

docker exec -it mysql_primary mysql -uroot -ppass123 -e "GRANT REPLICATION SLAVE ON *.* TO 'piuw_dev'@'%'; FLUSH PRIVILEGES;"

# Change replica to point to the primary mysql server
docker exec -it mysql_secondary mysql -uroot -ppass123 -e "CHANGE MASTER TO MASTER_HOST='db_primary', MASTER_PORT=3306, MASTER_USER='piuw_dev', MASTER_PASSWORD='zxcv123', MASTER_LOG_FILE='mysql-bin.000005', MASTER_LOG_POS=536, MASTER_CONNECT_RETRY=60, GET_MASTER_PUBLIC_KEY=1;"
# docker exec -it mysql_secondary mysql -uroot -ppass123 -e "CHANGE MASTER TO MASTER_HOST='db_primary', MASTER_PORT=3306, MASTER_USER='piuw_dev', MASTER_PASSWORD='zxcv123', MASTER_LOG_FILE='mysql-bin.000004', MASTER_LOG_POS=157, MASTER_CONNECT_RETRY=60, GET_MASTER_PUBLIC_KEY=1;"

docker exec -it mysql_primary mysql -uroot -ppass123 -e "STOP SLAVE;"
docker exec -it mysql_secondary mysql -uroot -ppass123 -e "STOP SLAVE;"
# docker exec -it mysql_secondary mysql -uroot -ppass123 -e "RESET SLAVE ALL;"
docker exec -it mysql_secondary mysql -uroot -ppass123 -e "START SLAVE;"

# Verify the replication status
docker exec -it mysql_secondary mysql -uroot -ppass123 -e "SHOW SLAVE STATUS\G"


# debug
docker exec -it mysql_primary mysql -uroot -ppass123 -e "SHOW VARIABLES LIKE 'server_id';"
docker exec -it mysql_secondary mysql -uroot -ppass123 -e "SHOW VARIABLES LIKE 'server_id';"