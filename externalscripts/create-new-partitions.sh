#!/bin/bash
mysql -u$(grep "^DBUser" /etc/zabbix/zabbix_server.conf|sed "s/^.*=//") -p$(grep "^DBPassword" /etc/zabbix/zabbix_server.conf|sed "s/^.*=//") <<< 'use zabbix; CALL zabbix.create_next_partitions("zabbix");'
