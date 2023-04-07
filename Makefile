container_names = mysql_master mysql_slave1 mysql_slave2
# wait MySQL container until it's ready for connections
define func
.PHONY: $(1)_check_ready
$(1)_check_ready:
	@while ! docker-compose logs $(1) | grep -q "ready for connections"; do sleep 1; done
	@echo "Container $(1) is ready."
endef
$(foreach name, $(container_names), $(eval $(call func,$(name))))

.PHONY: down
down:
	@docker-compose down -v

.PHONY: stop
stop:
	@docker-compose stop

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

.PHONY: ready
ready:
	@$(foreach name, $(container_names), $(MAKE) $(name)_check_ready;)

.PHONY: build
build:
	@./build.sh

.PHONY: master_status
master_status:
	@docker exec mysql_master sh -c 'mysql -u root -p123456 -e "SHOW MASTER STATUS \G"'

.PHONY: slave1_status slave2_status
slave1_status slave2_status:
	$(eval name := $(patsubst %_status,mysql_%,$@))
	@docker exec $(name) sh -c 'export MYSQL_PWD=123456; mysql -u root -e "SHOW SLAVE STATUS \G"' | sed -n 's/^\(.*\):[[:space:]]\(.\{1,\}\)$$/\1=\2/p'

.PHONY: master slave1 slave2
master slave1 slave2:
	docker exec -it mysql_$@ bash
