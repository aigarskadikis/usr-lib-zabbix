#!/bin/bash

# zabbix server or zabbix proxy for zabbix sender
contact=127.0.0.1

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
clock=$(date +%H%M)
volume=/backup
mysql=$volume/mysql/zabbix/$year/$month/$day/$clock
filesystem=$volume/filesystem/$year/$month/$day/$clock
if [ ! -d "$mysql" ]; then
  mkdir -p "$mysql"
fi

if [ ! -d "$filesystem" ]; then
  mkdir -p "$filesystem"
fi


echo -e "\nExtracting schema"
mysqldump \
--flush-logs \
--single-transaction \
--create-options \
--no-data \
zabbix > $mysql/schema.sql && \
xz $mysql/schema.sql

echo -e "\nExtracting data without dots in the graphs"
mysqldump \
--set-gtid-purged=OFF \
--flush-logs \
--single-transaction \
--no-create-info \
--ignore-table=zabbix.history \
--ignore-table=zabbix.history_log \
--ignore-table=zabbix.history_str \
--ignore-table=zabbix.history_text \
--ignore-table=zabbix.history_uint \
--ignore-table=zabbix.trends \
--ignore-table=zabbix.trends_uint \
zabbix > $mysql/data.sql && \
xz $mysql/data.sql

echo -e "\nFilesystem backup"

# sudo tar -cJf $filesystem/fs.conf.zabbix.tar.xz \
sudo tar -czvf $filesystem/fs.conf.zabbix.tar.gz \
--files-from "${0%/*}/backup_zabbix_files.list" \
--files-from "${0%/*}/backup_zabbix_directories.list" \
/usr/bin/zabbix_* \
$(grep zabbix /etc/passwd|cut -d: -f6)
