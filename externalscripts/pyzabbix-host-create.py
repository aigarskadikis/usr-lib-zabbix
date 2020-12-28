#!/usr/bin/env python
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

result=zapi.do_request('host.create',{"host": "sample2",
			"interfaces": [{"type": 1,"main": 1,"useip": 1,"ip": "192.168.3.1","dns": "","port": "10050"}],
			"groups": [{"groupid": "2"}],
			"templates": [{"templateid": "10001"}]})

