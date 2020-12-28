#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
move all hosts from one proxy to another proxy:
./proxy-round-robin.py SourceProxy DestinationProxy

offload a half of hosts from one proxy to another
./proxy-round-robin.py Proxy1 Proxy1 Proxy2

transfer all hosts from one proxy to others
./proxy-round-robin.py Source Destination1 Destination2 Destination3
"""

from pyzabbix import ZabbixAPI, ZabbixAPIException

# import credentials from external file
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

import sys
sys.path.insert(0, '/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available

ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False
# Login to the Zabbix API

zapi.login(config.username, config.password)

# count the arguments recieved

argument_count = len(sys.argv)

if len(sys.argv) > 1:

    print 'arguments received = ' + str(argument_count - 1)

    # calculate how many destination proxies will be involved

    destination_proxy_count = len(sys.argv) - 2
    print 'destination proxy count = ' + str(destination_proxy_count)

    # look if every proxy exists. [1:] means to skip the first array element which is filename of program

    print 'checking if all proxies exist..'
    for proxy in sys.argv[1:]:
        proxyid = zapi.proxy.get(output=['proxyid'],
                                 filter={'host': proxy})
        if proxyid:
            print proxyid
        else:
            print 'Proxy ' + proxy + ' not found'
            exit()

    # calculate the source proxy ID

    source_proxy = zapi.proxy.get(output=['proxyid'],
                                  filter={'host': sys.argv[1]})

    for id in source_proxy:

        # print the source proxy name + ID

        print sys.argv[1] + '=' + id['proxyid']

        # get all hosts which belongs to proxy. it may look weird to use proxy.get function to get host
        # but this is done because of usage of argument selectHosts

        proxies = zapi.proxy.get(proxyids=id['proxyid'],
                                 selectHosts='extend')

    # continue the program if two arguments was gived to program

    if len(sys.argv) > 2:

        # since we are using proxy.get function to get hosts, the hosts are located as a child element in the array
        # we need to double expand the array

        for proxy in proxies:
            for (idx, host) in enumerate(proxy['hosts']):
                destination = idx % destination_proxy_count + 1

                # get the whole proxy information

                deliver_to = zapi.proxy.get(output=['proxyid'],
                        filter={'host': sys.argv[destination + 1]})

                # extract proxy host ID from proxy information

                for dest in deliver_to:
                    print 'host with id:' + str(host['hostid']) \
                        + ' will be delivered to destination proxy ' \
                        + str(destination) + ' with id:' \
                        + str(dest['proxyid'])

                    # change the proxy id for the host

                    try:
                        result = zapi.host.update(hostid=host['hostid'
                                ], proxy_hostid=dest['proxyid'])
                    except ZabbixAPIException, e:

                    # output meaninfull error mesage if that exist

                        print e

        # show how many hosts are on source proxy

        host_count_per_proxy = len(proxy['hosts'])
        print 'host count per proxy ' + sys.argv[1] + ' = ' \
            + str(host_count_per_proxy)
    else:

        print 'no second argument was received. nothing to do'
else:
    print 'no argument was received. Please name a proxy server'
