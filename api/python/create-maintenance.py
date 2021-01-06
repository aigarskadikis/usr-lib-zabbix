#!/bin/python
"""
Shows a list of all current issues (AKA tripped triggers)
"""

import os
import json
import string
from pyzabbix import ZabbixAPI

#import credentials from external file
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

# define the API call from
# https://www.zabbix.com/documentation/3.4/manual/api/reference/maintenance/create
maintenance = {
	"groupids": ["24"],
	"name": "test_maintenance",
	"maintenance_type": 0,
	"active_since": 1532260800,
	"active_till": 1532347200,
	"description": "I am trying to create a maintenance via API",
	"timeperiods": [{
		"timeperiod_type": "0",
		"start_date": 1532268000,
		"period": 3600
	}]
}

def create_maintenance(zbx, maintenance):
  zbx.maintenance.create(maintenance)

# execute
create_maintenance(zapi, maintenance)
