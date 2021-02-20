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

  # get all templates. This will create a template array of human readable names
  templates=line['template'].split(";")

  # create an empty template ID array because we always operate with IDs
  templateIDarray=[]
     
  # go through all human readable template names 
  for template in templates:

   # query template name
   if zapi.template.get({"filter" : {"name" : template}}):

    # if query did not fail then template exist in the instance
    # extract exact template ID and put it template ID array
    templateIDarray.append({"templateid":int(zapi.template.get({"filter" : {"name" : template}})[0]['templateid'])})
   
   else:
    print ("Please create template '",template,"' in order to create host '",line['name'],"'")

  # get all human readable host group names
  groups=line['group'].split(";")
     
  # create a host group array which will consist with IDs. this is required to assign all host groups in one approach
  hostGroupIDarray=[]

  # go through all human readable host group names and validate if group exists in monitoring tool
  for hostGroup in groups:

   # perform a test API call to identify if host group exists
   if zapi.hostgroup.get({"filter":{"name":hostGroup}}):
         
    # if call was successful then extract exact host group ID and put it in host group ID array
    hostGroupIDarray.append({"groupid":int(zapi.hostgroup.get({"filter":{"name":hostGroup}})[0]['groupid'])})

   else:
    # let's create a new host group:
    print("Host group '",hostGroup,"' does not exist. Will create now")
         
    # create new host group, instantly extract houst group ID and add it to host group ID array
    hostGroupIDarray.append({"groupid":zapi.hostgroup.create({"name":hostGroup})['groupids'][0]})

  # create a host based on it's type in table
  if line['type']=='ZBX':
   print ("Zabbix agent hosts must be registered through functionality of agent auto registration")
 
  # if column represents an SNMP host
  if line['type']=='SNMP':

   # if all templates has been found in the instance then continue
   if len(templates)==len(templateIDarray):
    
    # check if proxy exists
    if zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}}):
     
     # if proxy exists, then extract proxy ID
     proxy_id=zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}})[0]['proxyid']

     # create a host behind proxy
     hostid = zapi.host.create ({
                            "host":line['name'],
                            "name":line['visible'],
                            "interfaces":[{"type":2,"dns":"","main":1,"ip":line['address'],"port": 161,"useip": 1,
                            "details":{"version":"2","bulk":"1","community":line['snmpcommunity']}}],
                            "groups":hostGroupIDarray,
                            "proxy_hostid":proxy_id,
                            "templates":templateIDarray})['hostids']

    else:
     print ("cannot create host '"+str(line['name'])+"' because proxy name '"+str(line['proxy'])+"' not found. please create it")

   else:
    print ("cannot create host '"+str(line['name'])+"' because not all templates exist in instance")

 else:
   print ("host '"+str(line['name'])+"' already exist")

file.close()
