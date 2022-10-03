#!/bin/bash

##############################################################
# Zabbix SNMP template DEV scenario
# scan which OID contains value mapping. create only them
# create items directly into interface by passing hostid
##############################################################

WORKDIR=/usr/lib/zabbix/snmp
MIBS="
ADVA-FSPR7-CAP-MIB
ADVA-FSPR7-DEF-MIB
ADVA-FSPR7-MIB
ADVA-FSPR7-MODULE-ENCRYPTION-MIB
ADVA-FSPR7-PM-MIB
ADVA-FSPR7-TC-MIB
ADVA-MIB
FspR7-LAYER2-MIB
FspR7-MIB
FspR7-SPEQ-MIB
"
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

echo "$MIBS" | grep -v "^$" | while IFS= read -r MIB
do {

# create 1 file there which is a very standalone file and does not interfer with system (to avoid MIB conflicts)
ls -lh $WORKDIR/$MIB

# the original MIB name usually hides behind
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB
grep 'DEFINITIONS ::= BEGIN' $WORKDIR/$MIB | grep -Eo "^\S+"

# Use 'snmptranslate' to list all available metrics
snmptranslate -Tz -m ./$MIB

grep "INTEGER" ~/$IP.log > /tmp/only.INTEGER.snmpwalk

# look for everything with Status
cd $WORKDIR && snmptranslate -Tz -m ./$MIB | grep -Eo "$ENTERPRISES.[0-9.]+" | \
awk '{ print length, $0 }' | sort -n | cut -d" " -f2- | tac | while IFS= read -r OBJECT
do {
USEFUL=$(grep "^\.$OBJECT" /tmp/only.INTEGER.snmpwalk) && \
echo "$USEFUL" | grep "INTEGER" > /dev/null

# if object is INTEGER then check if it has value map
if [ $? -eq 0 ]; then

echo -n ".1"

# check amount of lines
ELEMENTS=$(echo "$USEFUL" | wc -l)
if [ $ELEMENTS -lt 2 ]; then

echo -n ".$ELEMENTS"

# scan and create value map
snmptranslate -m ./$MIB -Td .$OBJECT | grep SYNTAX.*INTEGER.*{.*} > /dev/null && \
VALUE_MAP_NAME=$(snmptranslate -m ./$MIB .$OBJECT) && \
OIDNAME=$(snmptranslate -m ./$MIB .$OBJECT | grep -Eo "[a-zA-Z0-9]+$") && \
echo $OIDNAME && \
OIDDESCRIPTION=$(snmptranslate -m ./$MIB .$OBJECT -Td | tr -d '\n' | sed 's|^.*DESCRIPTION\s*||' | sed -e's/  */ /g' | sed 's|^\d034||' | sed 's|\d034.*$||') && \
snmptranslate -m ./$MIB -Td .$OBJECT | grep SYNTAX.*INTEGER.*{.*} | sed 's|^.*{||;s|}||;s|, |\n|g' && \
VALUE_MAP=$(snmptranslate -m ./$MIB -Td .$OBJECT | grep SYNTAX.*INTEGER.*{.*} | sed 's|^.*{||;s|}||;s|, |\n|g' | sed 's/^[ \t]*//' | sed 's|^|{"newvalue":"|' | sed 's|(|","value":"|' | sed 's|)|"},|' | tr -d '\n' | sed 's|,\s*$||' | sed 's|\d034|\\\d034|g') && \
echo "name: $VALUE_MAP_NAME" && \
echo "map: $VALUE_MAP" && \
VALUE_MAP_ID=$(zabbix_js -s create.value.map.js -p "
      {\"name\":\"$VALUE_MAP_NAME\",
   \"mappings\":\"$VALUE_MAP\",
\"api_jsonrpc\":\"$API_JSONRPC\",
        \"sid\":\"$SID\"}
" | grep -Eo "[0-9]+")


# create items and map with value map
echo "$USEFUL" | grep -Eo "^\S+" | while IFS= read -r OID
do {

curl --silent --insecure --request POST --header 'Content-Type: application/json-rpc' --data "
{
\"jsonrpc\": \"2.0\",
\"method\": \"item.create\",
\"params\": {
\"name\": \"$OIDNAME\",
\"key_\": \"$OID\",
\"description\": \"$OIDDESCRIPTION\",
\"snmp_oid\": \"$OID\",
\"hostid\": \"$HOSTID\",
\"type\": 20,
\"value_type\": 3,
\"interfaceid\": \"$INTERFACEID\",
\"valuemapid\":\"$VALUE_MAP_ID\",
\"delay\": \"1m\"
},
\"auth\": \"$SID\",
\"id\": 1
}
" $API_JSONRPC | jq . && \
echo "VALUE_MAP_ID is $VALUE_MAP_ID"

} done

else
echo -n ".$ELEMENTS" 

fi

else
echo -n '4'

# end of amount of elements
fi

} done

# end of MIBS loop
} done
zabbix_server -R config_cache_reload



