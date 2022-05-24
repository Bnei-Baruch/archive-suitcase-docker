#!/usr/bin/env bash
set +e
set -x

echo "sync production backup"
docker-compose -f ~/archive-docker/docker-compose-oneoff.yml run -T --rm sync

echo "stop services"
docker-compose stop

echo "restore mdb"
docker-compose start postgres_mdb
docker-compose exec -T postgres_mdb /bin/bash -c 'PGPASSWORD=$MDB_POSTGRES_PASSWORD psql -U postgres -d postgres -f /backup/mdb_dump.sql'

echo "start services"
docker-compose start

echo "restore elastic"
sleep 10s
curl -XPOST localhost:9200/_all/_close
sleep 5s
curl -XPOST localhost:9200/_snapshot/backup/full/_restore
