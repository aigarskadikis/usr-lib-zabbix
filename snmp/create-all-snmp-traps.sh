#!/bin/bash

##############################################################
# Zabbix SNMP template DEV scenario
# scan which OID contains value mapping. create only them
# create items directly into interface by passing hostid
##############################################################

WORKDIR=/usr/lib/zabbix/snmp
MIB=SOCOMECUPS-MIB-5-01
ENTERPRISES=1.3.6.1.4.1.4555
API_JSONRPC=https://zabbix.aigarskadikis.com/api_jsonrpc.php
SID=$(cat ~/.sid)
HOSTID=13563
IP=10.100.0.5
HOST_NAME="Net Vision v5"
PORT=161
# GET INTERFACE ID
INTERFACEID=$(curl --silent --insecure --request POST --header 'Content-Type: application/json-rpc' --data "{\"jsonrpc\":\"2.0\",\"method\":\"hostinterface.get\",\"params\":{\"output\":[\"interfaceid\"],\"hostids\":\"$HOSTID\",\"filter\":{\"main\":\"1\",\"port\":\"161\"}},\"auth\":\"$SID\",\"id\":1}" $API_JSONRPC | jq -r .result[0].interfaceid)

# make sure standart MIBS are installed in the system
cd /usr/share/snmp/mibs && ls -1

# create directory 'dev' to start developent
mkdir -p $WORKDIR

# create 1 file there which is a very standalone file and does not interfer with system (to avoid MIB conflicts)
ls -lh $WORKDIR/$MIB

# the original MIB name usually hides behind
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB | grep -Eo "^\S+"

##############################################################
# SNMP traps - trap description contains keyword CRITICAL
##############################################################


cd $WORKDIR && snmptranslate -Tz -m ./$MIB | grep Trap | grep -Eo "$ENTERPRISES.[0-9.]+" | while IFS= read -r OID
do {
snmptranslate -m ./$MIB $(echo .$OID | sed 's|\.[0-9]\+$||') -Td | grep 'TRAP-TYPE' &&
OIDNAME=$(snmptranslate -m ./$MIB .$OID) && \
OID_ESC=$(echo .$OID | sed 's|\.|\\\\.|g') && \
OIDDESCRIPTION=$(snmptranslate -m ./$MIB .$OID -Td | tr -d '\n' | sed 's|^.*DESCRIPTION\s*||' | sed -e's/  */ /g' | sed 's|^\d034||' | sed 's|\d034||g' | sed 's|::=.*$||') && \
echo $OIDNAME && \
echo $OID && \
echo \"key_\": \"snmptrap[\\\"\\\\s$OID_ESC\\\\s\\\"]\", && \
curl --silent --insecure --request POST --header 'Content-Type: application/json-rpc' --data "
{
\"jsonrpc\": \"2.0\",
\"method\": \"item.create\",
\"params\": {
\"name\": \"$OIDNAME\",
\"key_\": \"snmptrap[\\\"\\\\s$OID_ESC\\\\s\\\"]\",
\"description\": \"$OIDDESCRIPTION\",
\"hostid\": \"$HOSTID\",
\"type\": 17,
\"value_type\": 2,
\"interfaceid\": \"$INTERFACEID\",
\"delay\": \"30s\"
},
\"auth\": \"$SID\",
\"id\": 1
}
" $API_JSONRPC | jq . && \
curl --silent --insecure --request POST --header 'Content-Type: application/json-rpc' --data "
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"trigger.create\",
    \"params\": [
        {
            \"description\": \"$(echo "$OIDDESCRIPTION")\",
            \"expression\": \"{$HOST_NAME:snmptrap[\\\"\\\\s$OID_ESC\\\\s\\\"].nodata(1d)}=0\",
                        \"priority\":\"4\"
        }
    ],
\"auth\": \"$SID\",
    \"id\": 1
}
" $API_JSONRPC | jq . && \
echo
} done




