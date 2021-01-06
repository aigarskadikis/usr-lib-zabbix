#!/usr/bin/python

from pyzabbix import ZabbixAPI
import ipaddress
import re
import netaddr
import sys
from netaddr import *

#define function to convert from hex mac to dec max
def hexmactodecmac(hexmac):
    hexmac = re.findall(r'.{1,2}', hexmac, re.DOTALL)
    decmac = '.'.join(str(int(i, 16)).zfill(1) for i in hexmac)
    return decmac


class mac_custom(mac_unix): pass
mac_custom.word_fmt = '%.2X'

#import api credentials from different file
sys.path.insert(0,'/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

#query the last value from key 'ipNetToMediaPhysAddress'. 'key_' is column name
items = zapi.item.get(
                output=['lastvalue'],
                filter={'key_':'ipNetToMediaPhysAddress['+sys.argv[1]+']'})
for item in items:
        dev_mac = EUI(item['lastvalue'], dialect=mac_custom)

mac_str = str(dev_mac)
print 'mac: ' + mac_str
mac_str = mac_str.replace(':','')

mac = hexmactodecmac(mac_str)


items = zapi.item.get(
                output=['lastvalue','hostid'],
                filter={'name':'MAC Port '+ mac +' VLAN'})

print 'key: ' + 'MAC Port '+ mac +' VLAN'
print 'oct: ' + mac
for item in items:
        port = item['lastvalue']
        hostid = item['hostid']
print 'port: ' + port
print 'hostid: ' + hostid
hosts = zapi.host.get(
                output=['name'],
                filter={'hostid':hostid})
for host in hosts:
        hostname = host['name']
print 'hostname: ' + hostname

interfaces = zapi.hostinterface.get(
                output=['ip'],
                filter={'hostid':hostid})

for interface in interfaces:
        ip_address = interface['ip']

print 'IP Address:' + ip_address

hosts = zapi.host.get(
                output = ['hostid'],
                filter = {'host':sys.argv[1]})
for host in hosts:
        orig_hostid = host['hostid']
print 'orig_hostid: ' + orig_hostid


triggers = zapi.trigger.get(
#               hostids = orig_hostid,
                host = sys.argv[1],
                output = ['triggerid'],
                filter = {'description':'On {HOST.HOST} ICMP is down'})

for trigger in triggers:
        triggerid = trigger['triggerid']
print triggerid

#zapi.do_request('trigger.update', {'triggerid': triggerid,'tags': [{'tag' : 'SWITCH_IP',"value" : ip_address}] })

