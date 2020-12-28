#!/usr/bin/python

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

hosts = zapi.host.get(
  output = ['name'],
  filter = {
    'hostid': sys.argv[1]
  })

for host in hosts:
  print host['name']
replacement = zapi.host.get(
  output = ['hostid'],
  filter = {
    'name': sys.argv[2]
  })
if replacement:
  print sys.argv[2] + ' exists'
else :
  zapi.do_request('host.update', {
    'hostid': sys.argv[1],
    'name': sys.argv[2]
  })
