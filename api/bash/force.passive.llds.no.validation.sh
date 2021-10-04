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
" $url | jq .result[].itemid
)

ARRAY2MOD=$(
echo "$LLDIDS" | sed 's|^|{"type":"6","request":{"itemid":|;s|$|}},|' | tr -cd '[:print:]' | sed 's|,$||'
)

# print on screen what kind of IDs will receive a check now
echo "[$ARRAY2MOD]" | jq .

# execute check now
curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"task.create\",
    \"params\": [$ARRAY2MOD],
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url

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

