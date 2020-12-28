#!/usr/bin/env python
import csv
from pyzabbix import ZabbixAPI
from pprint import pprint
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False
zapi.login(config.username, config.password)


file = open('hostgroups.txt', 'r')
list = file.read().splitlines()
file.close()

for group in list:
 try:
  e=zapi.hostgroup.create({"name":group})
 except Exception as e:
  print group,"already exists"
