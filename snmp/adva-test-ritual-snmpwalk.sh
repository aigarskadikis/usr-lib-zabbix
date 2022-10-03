#!/bin/bash

##############################################################
# Zabbix SNMP template DEV scenario
# scan which OID contains value mapping. create only them
# create items directly into interface by passing hostid
##############################################################

WORKDIR=/usr/lib/zabbix/snmp
MIB=ADVA-MIB
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
snmpwalk -c'public' -v'2c' $IP:$PORT . | head

# create directory 'dev' to start developent
mkdir -p $WORKDIR

# create 1 file there which is a very standalone file and does not interfer with system (to avoid MIB conflicts)
ls -lh $WORKDIR/$MIB

# the original MIB name usually hides behind
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB | grep -Eo "^\S+"

# Use 'snmptranslate' to list all available metrics
snmptranslate -Tz -m ./$MIB

# based on previous keyword, print all OIDs
snmptranslate -Tz -m ./$MIB | grep Status | grep -Eo "1\.3\.6\.[0-9.]+"

echo 123
cd $WORKDIR && snmptranslate -Tz -m ./$MIB | grep Status | grep -Eo "$ENTERPRISES.[0-9.]+" | while IFS= read -r OID
do {
snmpwalk -c'public' -v'2c' $IP:$PORT .$OID > /dev/null && \
snmptranslate -m ./$MIB -Td .$OID | grep SYNTAX.*INTEGER.*{.*} > /dev/null && \
snmpwalk -On -c'public' -v'2c' $IP:$PORT .$OID.0 && \
echo .$OID.0 && \
VALUE_MAP_NAME=$(snmptranslate -m ./$MIB .$OID) && \
OIDNAME=$(snmptranslate -m ./$MIB .$OID | grep -Eo "[a-zA-Z0-9]+$") && \
echo $OIDNAME && \
OIDDESCRIPTION=$(snmptranslate -m ./$MIB .$OID -Td | tr -d '\n' | sed 's|^.*DESCRIPTION\s*||' | sed -e's/  */ /g' | sed 's|^\d034||' | sed 's|\d034.*$||') && \
snmptranslate -m ./$MIB -Td .$OID | grep SYNTAX.*INTEGER.*{.*} | sed 's|^.*{||;s|}||;s|, |\n|g' && \
VALUE_MAP=$(snmptranslate -m ./$MIB -Td .$OID | grep SYNTAX.*INTEGER.*{.*} | sed 's|^.*{||;s|}||;s|, |\n|g' | sed 's/^[ \t]*//' | sed 's|^|{"newvalue":"|' | sed 's|(|","value":"|' | sed 's|)|"},|' | tr -d '\n' | sed 's|,\s*$||' | sed 's|\d034|\\\d034|g') && \
echo $VALUE_MAP
} done
zabbix_server -R config_cache_reload



