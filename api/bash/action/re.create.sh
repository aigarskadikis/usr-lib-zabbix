#!/bin/bash

# 1. set connection details
url=http://127.0.0.1:152/api_jsonrpc.php
user=Admin
password=zabbix

# 2. get authorization token
auth=$(curl -s -X POST \
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

echo $auth

curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"action.get\",
    \"params\": {
        \"output\": \"extend\",
        \"selectOperations\": \"extend\",
        \"selectRecoveryOperations\": \"extend\",
        \"selectAcknowledgeOperations\": \"extend\",
        \"selectFilter\": \"extend\",
        \"filter\": {
            \"eventsource\": 0
        }
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url | jq '.result[].name'

# 4. logout user
curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.logout\",
    \"params\": [],
    \"id\": 1,
    \"auth\": \"$auth\"
}
" $url

