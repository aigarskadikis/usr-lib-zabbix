#!/usr/bin/python

from pyzabbix import ZabbixAPI, ZabbixAPIException

# import credentials from external file
import sys
from pprint import pprint
sys.path.insert(0, '/var/lib/zabbix')
import config
# we will search latest very latest values
import time

# set current unixtime in varible and print it outloud
ctime = time.time()

ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

# latest 'Free swap space' values on 'Zabbix server' in laste 5 minutes
print
print "Current unixtime:"
print ctime
print

print "Execute only filter and use itemid:"
var = zapi.history.get(filter={"itemid":"23309"},history=3, time_from = ctime-300, time_till = ctime)
pprint(var)
print

print "Use parameters: 'hostids' and 'itemids':"
var = zapi.history.get(hostids=10084,itemids=23309,history=3, time_from = ctime-300, time_till = ctime)
pprint(var)
print

