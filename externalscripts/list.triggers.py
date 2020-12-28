#!/usr/bin/env python3

from datetime import datetime
import json
import requests
import sys
import pprint

url = 'http://127.0.0.1/api_jsonrpc.php'

timeout = 900.0


def switch_severity(sev_in_num):
    switcher = {
        "0": "Not Defined",
        "1": "Information",
        "2": "Warning",
        "3": "Average",
        "4": "High",
        "5": "Disaster"
    }
    return switcher.get(sev_in_num, "Not Defined")

def zuser_login():
    payload = {'jsonrpc': '2.0',
               'method': 'user.login',
               'params': {
                   'user': 'Admin',
                   'password': 'zabbix'
               },
               'id': 1
               }
    return payload

def zhost_get(token, namedhost):
    plhost = {"jsonrpc": "2.0",
              "method": "host.get",
              "params": {"output": [
                  "hostid", "host", "status", "available", "proxy_host", "templated_host"
              ],
                  "selectInterfaces": [
                  "interfaceid", "ip"
              ],
                  "filter": {"status": [0],
                             "host": namedhost
                             },
                  "preservekeys": True
              },
              "id": 2,
              "auth": token
              }
    return plhost


def zproxy_get(token):
    plproxy = {"jsonrpc": "2.0",
               "method": "proxy.get",
               "params": {"output": [
                   "proxyid", "host", "status"
               ],
                   "filter": {"status": [5]
                              }
               },
               "id": 2,
               "auth": token
               }
    return plproxy


def zproxy_get_w_hostmember(token):
    plproxy_w_host = {"jsonrpc": "2.0",
                      "method": "proxy.get",
                      "params": {"output": "host",
                                 "selectHosts": ["proxy_hostid", "host", "hostid"
                                                 ],
                                 "filter": {"status": [5]
                                            }
                                 },
                      "id": 2,
                      "auth": token
                      }
    return plproxy_w_host


def zitem_get(token, items):
    plproxy_w_host = {"jsonrpc": "2.0",
                      "method": "item.get",
                      "params": {"output": ['name', 'itemid'],
                                 "itemids": items,
                                 "selectApplications": ['name'],
                                 "preservekeys": True
                                 },
                      "id": 2,
                      "auth": token
                      }
    return plproxy_w_host


def ztrigger_get(token, hhost_id):
    pltrigger = {"jsonrpc": "2.0",
                 "method": "trigger.get",
                 "params": {"output": [
                     "triggerid", "description", "expression", "priority",
                 ],
                     "selectItems": ["itemid"],
                     "expandDescription": True,
                     "expandExpression": True,
                     "filter": {
                     "status": 0
                 },
                     "hostids": hhost_id,
                     "preservekeys": True
                 },
                 "id": 2,
                 "auth": token
                 }
    return pltrigger


def ztemplate_get(token):
    pltemplate = {"jsonrpc": "2.0",
                  "method": "template.get",
                  "params": {"output": ["templateid", "host"],
                             "selectHosts": ["hostid", "host"],
                             "selectParentTemplates": ["templateid", "host"]
                             },
                  "id": 2,
                  "auth": token
                  }
    return pltemplate


def zapplication_get(token, h_shost_id, t_triggeritemid):
    plapplicat = {"jsonrpc": "2.0",
                  "method": "application.get",
                  "params": {"output": ["applicationid", "hostid", "name"],
                             "hostids": h_shost_id,
                             "itemids": t_triggeritemid,
                             "filter": {"itemid": [t_triggeritemid], "hostids": [h_shost_id]},
                             },
                  "id": 2,
                  "auth": token
                  }
    return plapplicat

len_arg = len(sys.argv)
if(len_arg <= 1):
    namedhost = ""
else:
    namedhost = sys.argv[1]

payload = zuser_login()
r = requests.get(url, json=payload, timeout=timeout)
rc = r.status_code
if (rc == 200):
    y = r.json()
    token = y['result']
    print(token)

if (token != None):
    namedhost = "Zabbix server"
    plhost = zhost_get(token, namedhost)
    gethost = requests.get(url, json=plhost, timeout=timeout)
    ghost_rc = gethost.status_code
    if (ghost_rc == 200):
        ghost_js = gethost.json()
        for hostid in ghost_js['result']:
            h_fhost = ghost_js['result'][hostid]['host']
            pprint.pprint(ghost_js['result'][hostid])
            h_shost = h_fhost.split(".", 1)
            print("[DEBUG] " +
                  datetime.now().strftime("%d-%b-%Y %H:%M:%S")+"---"+h_fhost)
            h_shost_id = ghost_js['result'][hostid]['hostid']
            h_hostip = ghost_js['result'][hostid]['interfaces'][0]['ip']
            pltrigger = ztrigger_get(token, h_shost_id)
            gettrigger = requests.get(url, json=pltrigger, timeout=timeout)
            gtrigger_rc = gettrigger.status_code
            if (gtrigger_rc != 200):
                continue

            gtrigger_js = gettrigger.json()
            triggers = dict()
            tr_items = list()
            for trigger_id in gtrigger_js['result']:
                trigger_data = gtrigger_js['result'][trigger_id]
                triggers[trigger_id] = dict()
                triggers[trigger_id]['description'] = trigger_data['description']
                triggers[trigger_id]['expression'] = trigger_data['expression'].replace(
                    '\r', '').replace('\n', ' ')
                triggers[trigger_id]['priority'] = trigger_data['priority']
                items = list()
                for item_data in trigger_data['items']:
                    items.append(item_data['itemid'])
                triggers[trigger_id]['items'] = items
                tr_items += items
                triggers[trigger_id]['priority_desc'] = switch_severity(
                    trigger_data['priority'])

            print("[DEBUG] "+datetime.now().strftime("%d-%b-%Y %H:%M:%S") +
                  "---"+h_fhost+"---"+trigger_data['description']) 

            plitem = zitem_get(token, tr_items)
            getitem = requests.get(url, json=plitem, timeout=timeout)
            gitem_rc = getitem.status_code
            if (gitem_rc != 200):
                continue
            gitem_js = getitem.json()
            tr_items = gitem_js['result']

            for trigger_id in triggers:
                trigger_data = triggers[trigger_id]
                trigger_items = trigger_data['items']
                trigger_descr = trigger_data['description']
                trigger_exp = trigger_data['expression']
                trigger_priority = trigger_data['priority_desc']

                application_name = list()

                for item_id in trigger_items:
                    if item_id in tr_items:
                        for app_data in tr_items[item_id]['applications']:
                            application_name.append(app_data['name'])
                print(h_fhost + "~" + h_shost[0] + "~" + h_hostip + "~" + '/'.join(
                    application_name) + "~" + trigger_descr + "~" + trigger_exp + "~" + trigger_priority)

reqlogout = {"jsonrpc": "2.0", "method": "user.logout",
             "params": [], "id": 1, "auth": token}
out = requests.get(url, json=reqlogout, timeout=timeout)
outrc = out.status_code
if(outrc == 200):
    print("Exit ... User logout successful")
