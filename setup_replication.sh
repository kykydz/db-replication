#!/bin/bash

echo "Step [1] Starting docker compose..."
docker compose -f docker-compose.yaml up -d

echo "Restarting server after initial configuration..."
docker restart db_master_svc db_replica_svc
echo "Restarted successfully!"

# Wait for 5 seconds
echo "Waiting for for both DB server to be ready..."
sleep 5

echo "Step [2] Grant replication user 'piuw_dev'"
docker exec -it db_master_svc mysql -uroot -ppass123 -e \
    "GRANT REPLICATION SLAVE ON *.* TO 'piuw_dev'@'%'; \
    FLUSH PRIVILEGES;"
echo "Granted successfully!"

echo "Waiting for for both DB server to be ready..."
sleep 5

# check master status, for: getting which log filename and position, save into OUTPUT
echo "Step [3] Getting master LOG_FILE and LOG_POSITION..."
docker exec -i db_master_svc mysql -uroot -ppass123 -e "SHOW MASTER STATUS;" > master_status.txt
export MASTER_LOG_FILE=$(awk 'NR==2 {print $1}' master_status.txt)
export MASTER_LOG_POSITION=$(awk 'NR==2 {print $2}' master_status.txt)
echo "Get master status successfully!"
echo "MASTER_LOG_FILE=$MASTER_LOG_FILE"
echo "MASTER_LOG_POSITION=$MASTER_LOG_POSITION"

# Change replica to point to the primary mysql server
echo "Step [4] Change replica to point to the master db server..."
docker exec -it db_replica_svc mysql -uroot -ppass123 -e \
    "CHANGE MASTER TO MASTER_HOST='db_network_master',\
    MASTER_PORT=3306, MASTER_USER='piuw_dev', \
    MASTER_PASSWORD='zxcv123', \
    MASTER_LOG_FILE='$MASTER_LOG_FILE', \
    MASTER_LOG_POS=$MASTER_LOG_POSITION, \
    MASTER_CONNECT_RETRY=60, \
    GET_MASTER_PUBLIC_KEY=1;"
echo "Changed successfully!"

echo "Step [5] Start replica db server..."
docker exec -it db_replica_svc mysql -uroot -ppass123 -e "START REPLICA;"

echo "Setup Replication DB Complete!"
