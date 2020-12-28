#!/usr/bin/env python
"""
show the groups where host belongs
"""

from pyzabbix import ZabbixAPI
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

#import credentials from external file
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config

try:
    # The hostname at which the Zabbix web interface is available
    ZABBIX_SERVER = config.url
    zapi = ZabbixAPI(ZABBIX_SERVER)
    # Disable SSL certificate verification
    zapi.session.verify = False
    # Login to the Zabbix API
    zapi.login(config.username, config.password)
    hostname = sys.argv[1]
    groups = "Groups assigned to the " + hostname + ":"
    
    # get host id
    for hostid in zapi.host.get(output = ['hostid'],filter = {'name': hostname}):
      id = hostid['hostid']
    
    # get all hostgroups by hostid 
    data = zapi.hostgroup.get(output='extend',hostids=id)

    # print intro, show the argument was received
    print groups
    
    # print all host groups
    for groupname in data:
      print groupname['name']
    
    # close session
    zapi.user.logout
except:
    print "No hostname defined"
