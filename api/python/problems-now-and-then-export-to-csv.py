#!/usr/bin/env python

import sys
from datetime import datetime
import time
import logging
from pyzabbix import ZabbixAPI
import pprint

#import credentials from external file
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config

try:
    start_time = sys.argv[1]
except:
    start_time = int(time.time()) - 86400

try:
    till_time = sys.argv[2]
except:
    till_time = int(time.time())


priorities = { 0 :'Not classified', 1 : 'Information', 2 : 'Warning', 3 : 'Average', 4 : 'High', 5 : 'Disaster'}

clock_format = '%Y-%m-%d %H:%M:%S'

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
# Disable SSL certificate verification
zapi.session.verify = False
# Login to the Zabbix API
zapi.login(config.username, config.password)

result = dict()

events = zapi.event.get(time_from = start_time, time_till = till_time, source = 0, object = 0, selectTags = ['tag', 'value'], selectAcknowledges = 'count', sortorder = 'DESC', output = 'extend')

for event in events:

    clock = int(event['clock'])
    triggerid = event['objectid']
    in_tags = event['tags']
    is_ack = event['acknowledged']
    eventid = event['eventid']
    r_eventid = event['r_eventid']
    status = 'PROBLEM'
    curr_time = datetime.utcfromtimestamp(int(time.time()))

    clock = datetime.utcfromtimestamp(int(clock))

    if r_eventid != '0':
        r_event_clock = zapi.event.get(eventids=r_eventid, source = 0, object = 0, selectAcknowledges = 'count', sortorder = 'DESC', output = ['eventid','clock'])
        r_clock = datetime.utcfromtimestamp(int(r_event_clock[0]['clock']))
        duration = r_clock - clock
        r_clock = r_clock.strftime(clock_format)
        status = 'RESOLVED'
    else:
        r_clock = '-'
        duration = curr_time - clock
    
    if is_ack == '1':
        is_ack = 'Yes'
    else:
        is_ack = 'No'

    trigger = zapi.trigger.get(triggerids = triggerid, expandDescription = True, selectHosts = ['name'], output = ['description', 'priority'])
    hostname = trigger[0]['hosts'][0]['name']
    trigger_name = trigger[0]['description']
    priority = priorities[int(trigger[0]['priority'])]

    clock = clock.strftime(clock_format)

    alerts = zapi.event.get(eventids = eventid, select_alerts = 'extend')
    tags = ''
    for tag in in_tags:
        tags = tags + ' ' + tag['tag'] + ': ' + tag['value']

    print "%s;%s;%s;%s;%s;%s;%s;%s;%s;%s" % (priority, clock, r_clock, status, hostname, trigger_name, str(duration), is_ack, len(alerts), tags)

