#!/bin/env python
from pyzabbix import ZabbixAPI
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)
result = zapi.proxy.get()
print "{\"data\":["
for idx,elem in enumerate(result):
  print "{\"{#PNAME}\":\""+elem['host']+"\"}"
  # if this is not last element the write a comma
  if idx!=len(result)-1:
    print ","
print "]}"
