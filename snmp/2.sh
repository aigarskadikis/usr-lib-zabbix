#!/bin/bash

##############################################################
# Zabbix SNMP template DEV scenario
# scan which OID contains value mapping. create only them
# create items directly into interface by passing hostid
##############################################################

WORKDIR=/usr/lib/zabbix/snmp
MIB=FspR7-MIB
ENTERPRISES=1.3.6.1.4.1.2544
API_JSONRPC=https://zabbix.aigarskadikis.com/api_jsonrpc.php
SID=$(cat ~/.sid)
HOSTID=13593
IP=10.100.0.7
HOST_NAME="10.100.0.7"
PORT=161
# GET INTERFACE ID
INTERFACEID=$(curl --silent --insecure --request POST --header 'Content-Type: application/json-rpc' --data "{\"jsonrpc\":\"2.0\",\"method\":\"hostinterface.get\",\"params\":{\"output\":[\"interfaceid\"],\"hostids\":\"$HOSTID\",\"filter\":{\"main\":\"1\",\"port\":\"161\"}},\"auth\":\"$SID\",\"id\":1}" $API_JSONRPC | jq -r .result[0].interfaceid)

# get 'snmpwalk' command working
# snmpwalk -c'public' -v'2c' $IP:$PORT . | head

# create directory 'dev' to start developent
mkdir -p $WORKDIR

# create 1 file there which is a very standalone file and does not interfer with system (to avoid MIB conflicts)
ls -lh $WORKDIR/$MIB

# the original MIB name usually hides behind
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB | grep -Eo "^\S+"

# Use 'snmptranslate' to list all available metrics
# snmptranslate -Tz -m ./$MIB

# based on previous keyword, print all OIDs
snmptranslate -Tz -m ./$MIB | grep Status | grep -Eo "1\.3\.6\.[0-9.]+"


cd $WORKDIR && snmptranslate -Tz -m ./$MIB | grep Status | grep -Eo "$ENTERPRISES.[0-9.]+" | while IFS= read -r OID
do {
VAR=$(snmpwalk -ObentU -c'public' -v'2c' $IP:$PORT .$OID) && \
echo "$VAR" | grep "INTEGER" && \
echo "$OID is useful"

} done
zabbix_server -R config_cache_reload



