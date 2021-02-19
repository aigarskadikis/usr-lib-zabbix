#!/usr/bin/env python3
# import hosts from CSV file to Zabbix via API
# and assign template and host group to them
# this code will aggregate all host group IDs
# and template IDs so only one host.create command needs to be executed

# python3 required
# dnf install python3-pip
# pip3 install zabbix_api
# script is tested and works with module 'zabbix_api'
# which is not the same as 'pyzabbix' !

import csv

from zabbix_api import ZabbixAPI

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# to not store API credentials inside the python code
# we will pick them up from home direcotry of zabbix
import sys
sys.path.insert(0,'/var/lib/zabbix')

# pip install config
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False
zapi.login(config.username, config.password)

# open file from same directory where python code is placed
file = open("devices.csv",'rt')
reader = csv.DictReader( file )

# take the file and read line by line
for line in reader:
 
 # check if this host exists in zabbix
 if not zapi.host.get({"filter":{"host" :line['name']}}):
  print (line['name'],"not yet registred")

  # check if proxy exists
  if zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}}):

   # observe proxy ID:
   proxy_id=zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}})[0]['proxyid']
   print (line['proxy'])

   # if proxy exists in instance then:
   if int(proxy_id)>0:

     # get all templates. This will create a template array
     templates=line['template'].split(";")

     # create an empty template ID array
     templateIDarray=[]
     
     for template in templates:
       
       # print human friendly template name
       print (template)

       # get template ID and add it to array
       templateIDarray.append({"templateid":int(zapi.template.get({"filter" : {"name" : template}})[0]['templateid'])})

     # print array which will be used for bulks
     print (templateIDarray)

     # get all host group IDs. This will create a host group array
     groups=line['group'].split(";")
     print (groups)
     
     hostGroupIDarray=[] 
     for hostGroup in groups:
       print (hostGroup)
       
       # get all host group IDs and put it in array. this is required so we can create a host with one command
       hostGroupIDarray.append({"groupid":int(zapi.hostgroup.get({"filter":{"name":hostGroup}})[0]['groupid'])})

     print (hostGroupIDarray)

     # create a host based on it's type in table
     if line['type']=='ZBX':
       print ("Zabbix agent hosts must be registered through functionality of agent auto registration")
#       hostid = zapi.host.create ({
#                            "host":line['name'],
#                            "interfaces":[{"type":1,"dns":"","main":1,"ip": line['address'],"port": 10051,"useip": 1}],
#                            "groups":hostGroupIDarray,
#                            "proxy_hostid":proxy_id,
#                            "templates":templateIDarray})['hostids']

     if line['type']=='SNMP':
       hostid = zapi.host.create ({
                            "host":line['name'],
                            "interfaces":[{"type":2,"dns":"","main":1,"ip":line['address'],"port": 161,"useip": 1,
                            "details":{"version":"2","bulk":"1","community":line['snmpcommunity']}}],
                            "groups":hostGroupIDarray,
                            "proxy_hostid":proxy_id,
                            "templates":templateIDarray})['hostids']

 else:
   print (line['name'],"already exist")

file.close()