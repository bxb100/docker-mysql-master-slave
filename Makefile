.PHONY: down
down:
	@docker-compose down -v

.PHONY: up
up:
	@docker-compose up -d

.PHONY: clean
clean:
	@rm -rf ./master/data/*
	@rm -rf ./slave?/data/*

.PHONY: ps
ps:
	@docker-compose ps

.PHONY: wait_ready
wait_ready:
	 @while ! docker-compose logs $$name | grep -q "ready for connections"; do sleep 1; done

.PHONY: ready
ready:
	@name=mysql_master ${MAKE} wait_ready
	@name=mysql_slave1 ${MAKE} wait_ready
	@name=mysql_slave2 ${MAKE} wait_ready
	@echo "All containers are ready for containers."

.PHONY: build
build:
	@./build.sh

.PHONY: master_status
master_status:
	@docker exec mysql_master sh -c 'mysql -u root -p123456 -e "SHOW MASTER STATUS \G"'

.PHONY: slave1_status
slave1_status:
	@docker exec mysql_slave1 sh -c 'mysql -u root -p123456 -e "SHOW SLAVE STATUS \G"'

.PHONY: slave2_status
slave2_status:
	@docker exec mysql_slave2 sh -c 'mysql -u root -p123456 -e "SHOW SLAVE STATUS \G"'

.PHONY: master
master:
	docker exec -it mysql_master bash

.PHONY: slave1
slave1:
	docker exec -it mysql_slave1 bash

.PHONY: slave2
slave2:
	docker exec -it mysql_slave2 bash


