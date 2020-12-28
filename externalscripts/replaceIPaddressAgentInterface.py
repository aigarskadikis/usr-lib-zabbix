#!/bin/env python
from pyzabbix import ZabbixAPI
import urllib3
from pprint import pprint
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False

zapi.login(config.username, config.password)

if len(sys.argv) > 1:
 
 # search for an agent interface with the followinf IP address
 for intid in zapi.hostinterface.get(output=["dns","ip","useip"],selectHosts=["hosts"],filter={"main": 1, "type": 1,"ip":sys.argv[1]}):
  print intid['interfaceid']
  
  if len(sys.argv) > 2:
   
   # replace the IP addres
   zapi.hostinterface.update(interfaceid=intid['interfaceid'],ip=sys.argv[2])
  
  else:
   print 'no second argument is given. cannot change the ip address'

else:
 print 'no argument was received. please type an existing IP address of zabbix agent device'

