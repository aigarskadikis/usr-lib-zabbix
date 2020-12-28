#!/bin/env python
from pyzabbix import ZabbixAPI
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False
zapi.login(config.username, config.password)
result = zapi.proxy.get()
print "{\"data\":["
for idx,elem in enumerate(result):
  print "{\"{#PNAME}\":\""+elem['host']+"\"}"
  # if this is not last element the write a comma
  if idx!=len(result)-1:
    print ","
print "]}"
#logout = zapi.user.logout()
logout = zapi.do_request('user.logout')
print logout

