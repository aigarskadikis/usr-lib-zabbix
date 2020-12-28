#!/usr/bin/env python
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
result = zapi.host.get(selectItems = ['itemid', 'name', 'key_'], selectTriggers = ['triggerid', 'description', 'expression'])
pprint(result)
