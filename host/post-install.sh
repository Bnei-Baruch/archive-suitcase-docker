#!/usr/bin/env bash
set +e
set -x

# Internal hosts
cat host/etc_hosts >> /etc/hosts

# required for elastic in docker
sysctl -w vm.max_map_count=262144

# ssh key for sync
# once generated it has to be copied into production-archive and restart the sync container there
ssh-keygen -t ed25519 -f sync/ssh/id_ed25519 -C "suitcase@bbdomain.org"
echo "copy sync/ssh/id_ed25519.pub to production sync server"
cat sync/ssh/id_ed25519.pub


# bring up services
docker-compose -f docker-compose.yml -f docker-compose-oneoff.yml pull
docker-compose up -d


# Setup elastic backup
curl -XPUT 'http://localhost:9200/_snapshot/backup' -H 'Content-Type: application/json' -d '{
    "type": "fs",
    "settings": {
        "location": "/backup/elastic",
        "compress": true
    }
}'


# sync backup from production and restore
host/backup_restore.sh

# skip this section if no public domain is ready
echo "modify public access domain if not default 'archive'"
  # nginx archive.conf -> location /mdb-api/  -> proxy_redirect + allow access (comment on allow / deny)
  # nginx cdn.archive.conf -> server_name
  # config/archive-ssr.env
  # config/mdb-links.toml (also need filer url)
  # ensure frontend builds (kmedia-mdb, mdb-admin) for this domain

git checkout -b local
git commit -am "local modifications"

# re-run everything
docker-compose -f docker-compose.yml up -d

# scale kmedia-mdb
docker-compose up -d --no-build --scale kmedia_mdb=3

# install cron jobs
sed "s|<INSTALL_DIR>|$(pwd)|g" host/archive.cron.txt > /etc/cron.d/archive

# CI/CD reminder
echo "REMINDER: setup ssh access for CI/CD agents"
