#!/bin/bash

#snmpget -v3 -l authPriv -a SHA -A SEynqqz6KE -x AES -X WaeBaEqUq9 -u zabbix -Oqv 127.0.0.1 .1.3.6.1.6.3.10.2.1.1.0 | tr -cd '[:print:]' | sed "s#\d034\|\s##g;s#^#0x#"

snmpget -v3 -l $3 -a SHA -A $4 -x AES -X $5 -u $2 -Oqv $1 .1.3.6.1.6.3.10.2.1.1.0 | tr -cd '[:print:]' | sed "s#\d034\|\s##g;s#^#createUser -e 0x#;s|$| $2 SHA $4 AES $5\n|"

# ./get-snmpEngineID-snmpget.sh 127.0.0.1 zabbix authPriv SEynqqz6KE WaeBaEqUq9
