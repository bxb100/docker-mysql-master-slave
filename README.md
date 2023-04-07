# Quick Start

```shell
make build
```

# Docker MySQL master-slave replication

MySQL 8.0 master-slave replication with using Docker.

~~Previous version based on MySQL 5.7 is available:
in [mysql5.7](https://github.com/vbabak/docker-mysql-master-slave/tree/mysql5.7) branch.~~ (see upstream)

## Run

To run this examples you will need to start containers with "docker-compose"
and after starting setup replication. See commands inside ./build.sh.

#### Create 3 MySQL containers with master-slaves STATEMENT-based replication[^1]

```shell
make build
```

#### Make changes to master

```shell
docker exec mysql_master sh -c "export MYSQL_PWD=123456; mysql -u root mydb -e 'create table code(code int); insert into code values (100), (200)'"
```

#### Read changes from slave

```shell
docker exec mysql_slave1 sh -c "export MYSQL_PWD=123456; mysql -u root mydb -e 'select * from code \G'"
```
```shell
docker exec mysql_slave2 sh -c "export MYSQL_PWD=123456; mysql -u root mydb -e 'select * from code \G'"
```

## Troubleshooting

#### Check Logs

```shell
docker-compose logs
```

#### Start containers in "normal" mode

> Go through "build.sh" and run command step-by-step.

#### Check running containers

```shell
make ps
```

#### Clean data dir

```shell
make clean
```

#### Run command inside "mysql_master"

```shell
make master_status
```

#### Run command inside "mysql_slave"

```shell
make slave1_status
```

```shell
make slave2_status
```

#### Enter into "mysql_master"

```shell
make master
```

#### Enter into "mysql_slave"

```shell
make slave1
```

```shell
make slave2
```

> 这个项目是为了 [尚硅谷ShardingSphere5实战教程（快速入门掌握核心）](https://www.bilibili.com/video/BV1ta411g7Jf/?p=14&share_source=copy_web&vd_source=75f28928f8e1001e7e53f0612a1d113d)
Mysql 主从快速启动, 所以和原始的配置不尽相同, 但是基本的原理是一样的.

[^1]: https://dev.mysql.com/doc/refman/8.0/en/replication-formats.html Not using row for this project
