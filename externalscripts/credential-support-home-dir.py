#!/usr/bin/env python

import sys

# import api credentials from different file
sys.path.insert(0,'~')
import gdrivecreds

# The hostname at which the Zabbix web interface is available
username = gdrivecreds.username
password = gdrivecreds.password

print username + " " + password
