#!/bin/sh


# MDB (postgres)
echo "MDB (postgres)"
rsync -avzhe ssh --delete production-archive:/data/backup/mdb_dump.sql.gz /data/backup
gunzip -f /data/backup/mdb_dump.sql.gz > /data/backup/mdb_dump.sql

# Elasticsearch
echo "elastic snapshot"
rsync -avzhe ssh --delete production-archive:/data/backup/elastic /data/backup

# Static site assets
echo "static site assets"
rsync -avzhe ssh --delete --exclude='generated' --exclude='unzip' production-archive:/data/assets/ /data/assets

# Save to RAID (TODO: some suitcases have no raid)
rsync -ac /data/assets/{sources,lessons,persons,logos,help} /data/raid/assets/
rsync -ac /data/backup/mdb_dump.sql.gz /data/raid/
