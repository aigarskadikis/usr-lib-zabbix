#!/bin/bash

DBHOST=10.133.112.87
DBUSER=zabbix
DBNAME=zabbixDB

VOLUME=/backup
# volume must belong to user which will run script

YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)
CLOCK=$(date +%H%M)

POSTGRES=$VOLUME/postgres/$DBNAME/$YEAR/$MONTH/$DAY/$CLOCK
# if directory does not exist then create it
[ ! -d "$POSTGRES" ] && mkdir -p "$POSTGRES"

cd /tmp
PGHOST=$DBHOST PGUSER=$DBUSER pg_dump \
--dbname=$DBNAME \
--file=schema.and.data.pg_restore.input \
--format=custom \
--blobs \
--verbose \
--exclude-schema=_timescaledb_internal \
--exclude-schema=_timescaledb_cache \
--exclude-schema=_timescaledb_catalog \
--exclude-schema=_timescaledb_config \
--exclude-table-data '*.history*' \
--exclude-table-data '*.trends*' && mv schema.and.data.pg_restore.input $POSTGRES
# only if the db dump is successfull, only then it will move file
