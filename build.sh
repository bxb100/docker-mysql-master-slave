#!/bin/bash
docker-compose down -v
rm -rf ./master/data/*
rm -rf ./slave/data/*
docker-compose build
docker-compose up -d

until docker exec mysql_master sh -c 'export MYSQL_PWD=123456; mysql -u root -e ";"'; do
	echo "Waiting for mysql_master database connection..."
	sleep 4
done

priv_stmt='CREATE USER "atguigu_slave"@"%" IDENTIFIED BY "123456"; GRANT REPLICATION SLAVE ON *.* TO "atguigu_slave"@"%"; FLUSH PRIVILEGES;'
docker exec mysql_master sh -c "export MYSQL_PWD=123456; mysql -u root -e '$priv_stmt'"

for i in "slave1" "slave2"; do
	until docker-compose exec mysql_${i} sh -c 'export MYSQL_PWD=123456; mysql -u root -e ";"'; do
		echo "Waiting for mysql_${i} database connection..."
		sleep 4
	done
done

MS_STATUS=$(docker exec mysql_master sh -c 'export MYSQL_PWD=123456; mysql -u root -e "SHOW MASTER STATUS"')
#  or sed $(echo "$MS_STATUS" | sed 'N;s/\n/ /' | awk '{print $6}')
MS_STATUS=$(echo "$MS_STATUS" | tail -n 1)
CURRENT_LOG=$(echo "$MS_STATUS" | awk '{print $1}')
CURRENT_POS=$(echo "$MS_STATUS" | awk '{print $2}')

echo "CURRENT_LOG: $CURRENT_LOG, CURRENT_POS: $CURRENT_POS"

start_slave_stmt="CHANGE MASTER TO MASTER_HOST='mysql_master',MASTER_USER='atguigu_slave',MASTER_PASSWORD='123456',MASTER_LOG_FILE='$CURRENT_LOG',MASTER_LOG_POS=$CURRENT_POS; START SLAVE;"
start_slave_cmd='export MYSQL_PWD=123456; mysql -u root -e "'
start_slave_cmd+="$start_slave_stmt"
start_slave_cmd+='"'

for i in "slave1" "slave2"; do
	docker exec mysql_${i} sh -c "$start_slave_cmd"
	docker exec mysql_${i} sh -c "export MYSQL_PWD=123456; mysql -u root -e 'SHOW SLAVE STATUS \G'"
done
