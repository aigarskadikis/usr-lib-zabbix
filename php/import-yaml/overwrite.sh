#!/bin/bash
find '/root/zabbix-source/templates/san' -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
php max_perf.php $1 $2 $TEMPLATE
} done
