#!/bin/bash

# 1. set connection details
url=http://127.0.0.1/api_jsonrpc.php
user=api
password=$1

ARG1=$2

# get authorization token
auth=$(curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
 \"jsonrpc\": \"2.0\",
 \"method\": \"user.login\",
 \"params\": {
  \"user\": \"$user\",
  \"password\": \"$password\"
 },
 \"id\": 1,
 \"auth\": null
}
" $url | \
jq -r '.result'
)

# get hostid
HOSTID=$(
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"output\": [\"hostid\"],
        \"filter\": {
            \"host\": [\"$ARG1\"]
        }
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | jq -r .result[0].hostid
)

# get discovery ids
LLDIDS=$(
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"discoveryrule.get\",
    \"params\": {
        \"output\": [\"itemid\"],
        \"hostids\": [$HOSTID]
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | jq -r .result[].itemid
)

# go through all items and check if this is passive item
for ITEM in $(
echo "$LLDIDS"
)
do

# extract the type of item to understand if it's passive or active
# we can execute "Check now" only for passive items
TYPE=$(
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"discoveryrule.get\",
    \"params\": {
        \"output\": [\"type\"],
        \"itemids\": [\"$ITEM\"]
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | jq -r .result[].type
)
echo
# if type is passive then execute discovery. Here all all types:
# 0, ITEM_TYPE_ZABBIX - Zabbix agent
# 2, ITEM_TYPE_TRAPPER - Zabbix trapper
# 3, ITEM_TYPE_SIMPLE - Simple check
# 5, ITEM_TYPE_INTERNAL - Zabbix internal
# 7, ITEM_TYPE_ZABBIX_ACTIVE - Zabbix agent (active) check
# 8, ITEM_TYPE_AGGREGATE - Aggregate
# 9, ITEM_TYPE_HTTPTEST - HTTP test (web monitoring scenario step)
# 10, ITEM_TYPE_EXTERNAL - External check
# 11, ITEM_TYPE_DB_MONITOR - Database monitor
# 12, ITEM_TYPE_IPMI - IPMI agent
# 13, ITEM_TYPE_SSH - SSH agent
# 14, ITEM_TYPE_TELNET - TELNET agent
# 15, ITEM_TYPE_CALCULATED - Calculated
# 16, ITEM_TYPE_JMX - JMX agent
# 17, ITEM_TYPE_SNMPTRAP - SNMP trap
# 18, ITEM_TYPE_DEPENDENT - Dependent item
# 19, ITEM_TYPE_HTTPAGENT - HTTP agent
# 20, ITEM_TYPE_SNMP - SNMP agent

# proceed only if it's passive item
if [ "$TYPE" -eq "0" ] || \
[ "$TYPE" -eq "3" ] || \
[ "$TYPE" -eq "5" ] || \
[ "$TYPE" -eq "8" ] || \
[ "$TYPE" -eq "10" ] || \
[ "$TYPE" -eq "11" ] || \
[ "$TYPE" -eq "12" ] || \
[ "$TYPE" -eq "13" ] || \
[ "$TYPE" -eq "14" ] || \
[ "$TYPE" -eq "15" ] || \
[ "$TYPE" -eq "16" ] || \
[ "$TYPE" -eq "19" ] || \
[ "$TYPE" -eq "20" ]
then

# execute check now
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"task.create\",
    \"params\": [{\"type\":\"6\",\"request\":{\"itemid\":\"$ITEM\"}}],
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url
echo

else
# this is active item
echo "Cannot execute Check now for Type: $TYPE"
fi

# end of loop of getting through discovery items
done

# logout user
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.logout\",
    \"params\": [],
    \"id\": 1,
    \"auth\": \"$auth\"
}
" $url > /dev/null

