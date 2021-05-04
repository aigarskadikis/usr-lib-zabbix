#!/bin/bash

# 1. set connection details
url=http://127.0.0.1/api_jsonrpc.php
user=api
password=zabbix

# 2. get authorization token
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

# 3. capture all SNMP host IDs which has an empty DNS field
# type:2 means SNMP hosts
HOST_IPS_WITH_EMPTY_DNS=$(curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostinterface.get\",
    \"params\": {
        \"output\": [
            \"interfaceid\",
            \"hostid\",
            \"ip\",
            \"dns\"
            ],
        \"filter\":{
            \"main\": \"1\",
            \"type\": \"2\"
        }
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | \
jq -r '.result[] | select (.dns == "") | .ip')

# Start a loop with IPs which has an DNS field empty 
echo "$HOST_IPS_WITH_EMPTY_DNS" | \
grep -v "^$" | \
while IFS= read -r IP
do {

# Perform nslookup and if it succeeds then continue to
# 1) Fetch again full characteristics of node, this is because
# host object and host interface are two different things and both must be updated
# 2) Update DNS field in the interface section
# 3) Replace host visiable name
echo -e "$IP\n"
nslookup $IP && \
FQDN=$(nslookup $IP | egrep -o "\S+corp.ds.gov.nt.ca") && \
NODE_TO_BE_UPDATED=$(curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostinterface.get\",
    \"params\": {
        \"output\": [
            \"interfaceid\",
            \"hostid\"
            ],
        \"filter\":{
            \"main\": \"1\",
            \"type\": \"2\",
	    \"ip\": \"$IP\"
        }
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | \
	jq -r '.result[]') && \
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"hostinterface.update\",
    \"params\": {
    \"interfaceid\": \"$(echo "$NODE_TO_BE_UPDATED" | jq -r .interfaceid)\",
        \"dns\": \"$FQDN\"
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | \
        jq -r '.result[]' && \
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.update\",
    \"params\": {
        \"hostid\": \"$(echo "$NODE_TO_BE_UPDATED" | jq -r .hostid)\",
        \"name\": \"$FQDN\"
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | \
        jq -r '.result[]'

} done

# 4. logout user
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

