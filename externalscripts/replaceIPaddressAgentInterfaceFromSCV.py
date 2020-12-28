#!/bin/env python
import csv
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

file = open("replaceIPaddressAgentInterface.csv",'rb')
reader = csv.DictReader( file )

for line in reader:

 # search for an agent interface with the following IP address
 for intid in zapi.hostinterface.get(output=["dns","ip","useip"],selectHosts=["hosts"],filter={"main": 1, "type": 1,"ip":line['oldIP']}):
  print intid['interfaceid']
  
  # replace the IP addres
  zapi.hostinterface.update(interfaceid=intid['interfaceid'],ip=line['newIP'])
  
file.close()
