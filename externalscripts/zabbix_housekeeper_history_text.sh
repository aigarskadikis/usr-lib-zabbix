#!/bin/bash

echo 'SET SESSION SQL_LOG_BIN=0;'
mysql zabbix -sN -e "SELECT CONCAT('DELETE FROM history_text where itemid=',items.itemid, ' AND clock < ',(UNIX_TIMESTAMP(NOW())-(items.history*3600*24)),';')
FROM items
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE hosts.status IN (0,1)
AND items.history like '%d'
AND items.value_type = 4"

