#!/bin/bash
destination=/backup/zabbix/mysql/raw
mkdir -p $destination
yesterday=$(date -d "1 DAY AGO" "+%Y-%m-%d")
echo "
history
history_uint
history_str
history_text
history_log
trends
trends_uint
" | \
grep -v "^$" | \
while IFS= read -r table; do {
echo $table
old=$(echo $table|sed "s|$|_old|")
if [ ! -f "$destination/$old.sql.xz.before.$yesterday" ]; then
mysqldump \
--flush-logs \
--single-transaction \
--no-create-info \
zabbix $table --where=" \
clock < UNIX_TIMESTAMP(\"$yesterday 00:00:00\") \
" | sed "s|$table|$old|" > $destination/$old.sql && \
xz $destination/$old.sql && \
mv $destination/$old.sql.xz $destination/$old.sql.xz.before.$yesterday
fi
} done
