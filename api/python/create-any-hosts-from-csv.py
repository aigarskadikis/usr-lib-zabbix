#!/usr/bin/env python3
# import hosts from CSV file to Zabbix via API
# and assign template and host group to them
# this code will aggregate all host group IDs
# and template IDs so only one host.create command needs to be executed

# for best management it's suggested that a one device can have only one master template
# this allows us to install all exceptions in template, avoide to install exceptions at host level

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
file = open("/tmp/devices.csv",'rt')
reader = csv.DictReader( file )

# take the file and read line by line
for line in reader:
 
 # check if this host exists in zabbix
 if not zapi.host.get({"filter":{"host":line['address']}}):
  print ("Host '"+str(line['address'])+"' is not yet registred. will register it now..")

  # get all templates. This will create a template array of human readable names
  templates=line['template'].split(";")
  
  # create an empty template ID array because we always operate with IDs 
  templateIDarray=[]

  # continue only if one template template name is in CSV file
  if len(templates)==1:

   # check if this template already exists in instance
   if zapi.template.get({"filter":{"name":line['template']}}):

    # if query did not fail then template exist in the instance
    # extract exact template ID and put it template ID array
    templateIDarray.append({"templateid":int(zapi.template.get({"filter":{"name":line['template']}})[0]['templateid'])})
    # it is silly to create an array which will always consist with one element
    # hovever this is unified syntax if we need to work with multiple objects
   
   else:
    print ("Template '"+str(line['template'])+"' does not exist. checking all dependencies to create master template")

    # a master template can contain multiple child templates. Let's create an array of child templates
    templatesInsideMaster=[]    

    # check if template 'Generic SNMP' exists
    if zapi.template.get({"filter":{"host":"Generic SNMP"}}):

     # if exists then pick up ID
     genericSNMPID=zapi.template.get({"filter":{"host":"Generic SNMP"}})[0]['templateid']
     
     # an 'templateid' attribute is mandatory
     templatesInsideMaster.append({"templateid":genericSNMPID})

    else:
     print ("Template 'Generic SNMP' does not exist")

    # define template groups array. an array is not really required, it can be a simple variabe too
    # but just to keep unified syntax we will define array
    templateGroupsIDarray=[]

    # check if template 'Templates/Master' exists
    if zapi.hostgroup.get({"filter":{"host":"Templates/Master"}}):

     # if previous step was successfull then template group exists. now extract exact template group id
     templateGroupsIDarray.append(int(zapi.hostgroup.get({"filter":{"name":["Templates/Master"]}})[0]['groupid']))

    else:
     print ("group 'Templates/Master' does not exist. Will create it now..")
     
     # TODO how to create a new master template

    print ("Creating a new master template '"+str(line['template'])+"'")
    templateIDarray.append({"templateid":int(zapi.template.create({
                           "host":line['template'],
                           "groups":{"groupid":templateGroupsIDarray[0]},
                           "templates":templatesInsideMaster})['templateids'][0])})

  # get all human readable host group names
  print ("all groups:",line['group'])
  groups=line['group'].split(";")

  # create a host group array which will consist with IDs. this is required to assign all host groups in one API call
  hostGroupIDarray=[]
     
  # go through all human readable host group names and validate if group exists in monitoring tool
  for hostGroup in groups:
  
   print ("parsing HG:",hostGroup)

   # perform a test API call to identify if host group exists
   if zapi.hostgroup.get({"filter":{"name":hostGroup}}):
         
    # if call was successful then extract exact host group ID and put it in host group ID array
    hostGroupIDarray.append({"groupid":int(zapi.hostgroup.get({"filter":{"name":hostGroup}})[0]['groupid'])})

   else:
    # let's create a new host group:
    print("Host group '"+str(hostGroup)+"' does not exist. Will create it now..")
         
    # create new host group, instantly extract houst group ID and add it to host group ID array
    hostGroupIDarray.append({"groupid":int(zapi.hostgroup.create({"name":hostGroup})['groupids'][0])})


  # if master template is persistent to instance
  if len(templateIDarray)==1:
    
   # a special override condition if proxy name is empty then tris host will be attached directly to master server
   if len(line['proxy'])==0:
     
    # create a host which is attached directly to master server (without zabbix proxy)
    print ("creating a new host '"+str(line['name'])+"' behind proxy '"+str(line['proxy'])+"'")
    hostid = zapi.host.create ({
                            "host":line['address'],
                            "name":line['name'],
                            "interfaces":[{"type":2,"dns":"","main":1,"ip":line['address'],"port": 161,"useip": 1,
                            "details":{"version":"2","bulk":"1","community":line['snmpcommunity']}}],
                            "groups":hostGroupIDarray,
                            "templates":templateIDarray})['hostids']

   # if proxy field is filled
   else:

    # try to query proxy
    if zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}}):
      
     # if previous query did not fail then pick up exact proxy ID
     proxy_id=zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}})[0]['proxyid']

     # create a host behind proxy
     hostid = zapi.host.create ({
                            "host":line['address'],
                            "name":line['name'],
                            "interfaces":[{"type":2,"dns":"","main":1,"ip":line['address'],"port": 161,"useip": 1,
                            "details":{"version":"2","bulk":"1","community":line['snmpcommunity']}}],
                            "groups":hostGroupIDarray,
                            "proxy_hostid":proxy_id,
                            "templates":templateIDarray})['hostids']

    else:
     print ("Host '"+str(line['address'])+"' has not been created because proxy name '"+str(line['proxy'])+"' not found. Please create proxy")

 else:
   print ("Host '"+str(line['address'])+"' already exist")

file.close()
