#!/usr/bin/env python

from pyzabbix import ZabbixAPI, ZabbixAPIException
from pprint import pprint
from datetime import datetime
import time
# import credentials from external file
import sys
sys.path.insert(0, '/var/lib/zabbix')
import config
# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

# set current unixtime in varible and print it outloud
ctime = time.time()

clock_format='%Y-%m-%d %H:%M:%S'

# 2 weeks
scope=120960

# 3 days
#scope=259200

events = zapi.event.get(time_from = ctime-scope, time_till = ctime, source = 0, object = 0, selectTags = ['tag', 'value'], selectAcknowledges = 'count', sortorder = 'DESC', output = 'extend')

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
    #priority = priorities[int(trigger[0]['priority'])]
    priority = 4

    clock = clock.strftime(clock_format)

    alerts = zapi.event.get(eventids = eventid, select_alerts = 'extend')
    tags = ''
    for tag in in_tags:
        tags = tags + ' ' + tag['tag'] + ': ' + tag['value']

    print "%s;%s;%s;%s;%s;%s;%s;%s;%s;%s" % (priority, clock, r_clock, status, hostname, trigger_name, str(duration), is_ack, len(alerts), tags)



