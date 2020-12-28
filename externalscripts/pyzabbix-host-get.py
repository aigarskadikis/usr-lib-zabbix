#!/usr/bin/python
"""
Shows a list of all current issues (AKA tripped triggers)
"""

#for argument support
import sys

#pip install pyzabbix
from pyzabbix import ZabbixAPI

#import api credentials from different file
sys.path.insert(0,'/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

#query host id by parsing hostname as argument 1
result = zapi.host.get (filter={"host" : "Zabbix server"})

#extract hostid from json string. host['hostid'] is array element with string identifier
for h in result:
  for key in sorted(h):
    print "%s: %s " % (key, h[key])
