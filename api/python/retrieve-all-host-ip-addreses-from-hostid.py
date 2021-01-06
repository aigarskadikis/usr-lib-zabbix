#!/bin/python
from pyzabbix import ZabbixAPI

#import credentials from external file
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

for host in zapi.item.get(output='extend',search={'key_':'icmppingloss[,100,40,1500,400]'}):
  for host_conn in zapi.hostinterface.get(output='extend',hostids=host['hostid']):
    print host_conn['ip']
