---
layout: memo
title: PostgreSQL cheatsheet
---

# Environment
## Install by apt
follow instruction of [postgres wiki](https://wiki.postgresql.org/wiki/Apt).

```sh
curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/apt.postgresql.org.gpg >/dev/null
sudo sh -c 'echo "deb [arch=amd64] http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt-get update
apt-cache show postgresql-15
```

**Note: `arch` should be specifed on sources.list.**

## Run on docker container
[PostgreSQL image](https://hub.docker.com/_/postgres)
```sh
docker run --name pg -e POSTGRES_PASSWORD=secret -p 5432:5432 -d postgres:15.3
```

## Attach running container
```sh
docker exec -it pg bash
```
## Flyway for PostgreSQL
- [Flyway >=9.1.2 hanging forever on concurrent index creation](https://github.com/flyway/flyway/issues/3508)

Use `-postgresql.transactional.lock=false` option

# Administration
## Get storage size of relations
- [Disk Usage](https://wiki.postgresql.org/wiki/Disk_Usage)
- [pg_total_relation_size](https://pgpedia.info/p/pg_total_relation_size.html)
