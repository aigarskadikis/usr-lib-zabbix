#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
list monitored and unmonitored hosts
"""

from pyzabbix import ZabbixAPI, ZabbixAPIException
from pprint import pprint
# import credentials from external file

import sys
sys.path.insert(0, '/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available

ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API

zapi.login(config.username, config.password)

# Get enabled hosts:
#hosts_en = zapi.host.get(monitored_hosts=1, output='extend'])
# Get disabled hosts:
#hosts_dis = zapi.host.get(monitored_hosts=0, output='query')
result2 = zapi.do_request('host.get',{'filter': {'status': 1},'output': 'extend'})

# Print output:
# print 'Monitored hosts: \t',len(hosts_en)

hosts_dis = [host['host'] for host in result2['result']]

print 'Un Monitored hosts: \t',len(hosts_dis)
pprint(hosts_dis)




# output='extend',search={'key_':'system.objectid'},sortfield='name'
