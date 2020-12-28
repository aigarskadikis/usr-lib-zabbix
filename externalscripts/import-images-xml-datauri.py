#!/usr/bin/env python

import os
import sys
import glob
from pprint import pprint
from pyzabbix import ZabbixAPI, ZabbixAPIException

sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
#zapi.session.verify = False
zapi.login(config.username, config.password)

if len(sys.argv) <= 1:
    print('Please provide directory with templates as first ARG or the XML file with template.')
    exit(1)

path = sys.argv[1]

rules = {
    'applications': {
        'createMissing': True,
    },
    'discoveryRules': {
        'createMissing': True,
        'updateExisting': True
    },
    'graphs': {
        'createMissing': True,
        'updateExisting': True
    },
    'groups': {
        'createMissing': True
    },
    'hosts': {
        'createMissing': True,
        'updateExisting': True
    },
    'images': {
        'createMissing': True,
        'updateExisting': True
    },
    'items': {
        'createMissing': True,
        'updateExisting': True
    },
    'maps': {
        'createMissing': True,
        'updateExisting': True
    },
    'screens': {
        'createMissing': True,
        'updateExisting': True
    },
    'templateLinkage': {
        'createMissing': True,
    },
    'templates': {
        'createMissing': True,
        'updateExisting': True
    },
    'templateScreens': {
        'createMissing': True,
        'updateExisting': True
    },
    'triggers': {
        'createMissing': True,
        'updateExisting': True
    },
    'valueMaps': {
        'createMissing': True,
        'updateExisting': True
    }
}



if os.path.isdir(path):
    print 'direcotry detected'
    #path = path/*.xml
    files = glob.glob(path+'/*.xml')
    for file in files:
        print(file)
        with open(file, 'r') as f:
            template = f.read()
            try:
                rrr=zapi.confimport('xml', template, rules)
                print(rrr)
            except ZabbixAPIException as e:
                print(e)
        print('')
elif os.path.isfile(path):
    print 'xml input detected'
    files = glob.glob(path)
    for file in files:
        with open(file, 'r') as f:
            template = f.read()
            try:
                zapi.confimport('xml', template, rules)
            except ZabbixAPIException as e:
                print(e)
else:
    print('I need a xml file')

