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

curl -ks -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"maintenance.create\",
    \"params\": {
        \"name\": \"Sunday maintenance\",
        \"active_since\": 1630692883,
        \"active_till\": 1630792883,
        \"tags_evaltype\": 0,
        \"groupids\": [
            \"2\"
        ],
        \"timeperiods\": [
            {
                \"timeperiod_type\": 0,
                \"start_time\": 64800,
                \"period\": 3600
            }
        ]
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url > /dev/null


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

