#!/usr/bin/env bash
set +e
set -x

echo "sync production backup"
docker-compose run -T --rm sync

echo "stop services"
docker-compose stop

echo "restore mdb"
docker-compose exec -T postgres_mdb /bin/bash -c 'psql -d postgres -f /backup/mdb_dump.sql.gz'

echo "start services"
docker-compose start

echo "restore elastic"
curl -XPOST localhost:9200/_all/_close
sleep 5s
curl -XPOST localhost:9200/_snapshot/backup/full/_restore
