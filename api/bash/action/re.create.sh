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

# start a loop to query names of all txt in current directory
ls -1 *.txt | sed 's|.txt||' | while IFS= read -r ACTIONNAME
do {
# check if this action name is already persistant in instance
ACTION_ID=$(curl -s -X POST \
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
" $url | jq -r ".result[] | select (.name == \"$ACTIONNAME\") | .actionid")
# if the action id is not empty then this action exsits
# must execute extra condition
if [ ! -z $ACTION_ID ]; then
echo $ACTION_ID

# delete this action
curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"action.delete\",
    \"params\": [
        \"$ACTION_ID\"
    ],
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url
fi
# read content of txt file to create a new action with the host titles
cat $ACTIONNAME.txt | while IFS= read -r HOST_NAME
do {
# query host id
HOST_ID_TO_INCLUE=$(
curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"host.get\",
    \"params\": {
        \"output\": [\"hostid\"],
        \"filter\": {
            \"host\": [
                \"$HOST_NAME\"
            ]
        }
    },
    \"auth\": \"$auth\",
    \"id\": 2
}
" $url | jq -r '.result[].hostid'
)
echo "$HOST_ID_TO_INCLUE"
} done

} done

# 4. logout user
LOG_OUT=$(curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.logout\",
    \"params\": [],
    \"id\": 1,
    \"auth\": \"$auth\"
}
" $url)

