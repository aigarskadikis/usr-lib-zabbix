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
  print (line['name'],"not yet registred. will register now")

  # check if proxy exists
  if zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}}):

   # observe proxy ID:
   proxy_id=zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}})[0]['proxyid']

   # if proxy exists in instance then:
   if int(proxy_id)>0:

     # get all templates. This will create a template array of human readable names
     templates=line['template'].split(";")

     # create an empty template ID array because we always operate with IDs
     templateIDarray=[]
    
     # go through all template names 
     for template in templates:

       # get template ID and add it to array
       templateIDarray.append({"templateid":int(zapi.template.get({"filter" : {"name" : template}})[0]['templateid'])})

     # get all host group IDs. This will create a host group array with human readable names
     groups=line['group'].split(";")
     
     # create a host group array. this is required to assign all host groups in one approach
     hostGroupIDarray=[]

     # go through all groups and validate if group exists in monitoring tool
     for hostGroup in groups:
       # try to query the host group ID
       try:
        if zapi.hostgroup.get({"filter":{"name":hostGroup}})[0]['groupid']:
         try:
          # if query was successfull then add this group ID in host group array
          hostGroupIDarray.append({"groupid":zapi.hostgroup.get({"filter":{"name":hostGroup}})[0]['groupid']})
         except:
          print ("hello")
       except:
        # if we failed to query host group ID, this is a sign we need to create it
        print("Host group '",hostGroup,"' does not exist. Will create now")
        # assign a newly created host group ID to the host group array
        hostGroupIDarray.append({"groupid":zapi.hostgroup.create({"name":hostGroup})['groupids'][0]})

     # create a host based on it's type in table
     if line['type']=='ZBX':
       print ("Zabbix agent hosts must be registered through functionality of agent auto registration")
 
     # if column represents an SNMP host
     if line['type']=='SNMP':
       hostid = zapi.host.create ({
                            "host":line['name'],
                            "name":line['visible'],
                            "interfaces":[{"type":2,"dns":"","main":1,"ip":line['address'],"port": 161,"useip": 1,
                            "details":{"version":"2","bulk":"1","community":line['snmpcommunity']}}],
                            "groups":hostGroupIDarray,
                            "proxy_hostid":proxy_id,
                            "templates":templateIDarray})['hostids']

 else:
   print (line['name'],"already exist")

file.close()
