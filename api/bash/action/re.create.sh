#!/bin/bash

# 1. set connection details
# url=http://127.0.0.1:152/api_jsonrpc.php
# user=Admin
# password=zabbix
url=$1
user=$2
password=$3

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
ls -1 *.hosts.txt | sed 's|.hosts.txt||' | while IFS= read -r ACTIONNAME
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
echo

# create an empty filter conditions. this is required to add multiple hosts in pool
FILTER_CONDITIONS=""

# read content of txt file to create a new action with the host titles
cat $ACTIONNAME.hosts.txt | while IFS= read -r HOST_NAME
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

# only if the hostid has been found, then include it in pool
if [ ! -z $HOST_ID_TO_INCLUE ]; then
echo "$HOST_ID_TO_INCLUE"
FILTER_CONDITIONS+="{\"conditiontype\":1,\"operator\":0,\"value\":\"$HOST_ID_TO_INCLUE\"},"
echo "$FILTER_CONDITIONS" | sed "s|.$||" > /tmp/FILTER_CONDITIONS.txt
fi

} done

# empty user array to deliver emails
OPMESSAGE_USR=""

# extract userID and mediatype ID for to understand where to deliver email
cat $ACTIONNAME.emails.txt | while IFS= read -r EMAIL
do {

ALL_USERS_AND_MEDIA=$(curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"user.get\",
    \"params\": {
        \"output\": [\"medias\"],
        \"selectMedias\": \"extend\"
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url)
# userid found
USER_ID_FOR_EXISTING_EMAIL=$(echo "$ALL_USERS_AND_MEDIA" | jq -r ".result[] | select (.medias[].sendto[] == \"$EMAIL\") | .medias[].userid")

MEDIA_ID_FOR_EXISTING_EMAIL=$(echo "$ALL_USERS_AND_MEDIA" | jq -r ".result[] | select (.medias[].sendto[] == \"$EMAIL\") | .medias[].mediaid")

# if user with this email was found
if [ ! -z "$USER_ID_FOR_EXISTING_EMAIL" ]; then
echo "UserID: $USER_ID_FOR_EXISTING_EMAIL"
OPMESSAGE_USR+="{\"userid\":\"$USER_ID_FOR_EXISTING_EMAIL\"},"
echo "$OPMESSAGE_USR" | sed "s|.$||" > /tmp/OPMESSAGE_USR.txt
echo "MediaID: $MEDIA_ID_FOR_EXISTING_EMAIL"
else
echo email $EMAIL has not been assigned to any user
fi

} done

# check if there were some emails detected
if [ ! -z "$(cat /tmp/OPMESSAGE_USR.txt)"]; then
# recreate action while containing all hosts in pool
curl -s -X POST \
-H 'Content-Type: application/json-rpc' \
-d " \
{
    \"jsonrpc\": \"2.0\",
    \"method\": \"action.create\",
    \"params\": {
        \"name\": \"$ACTIONNAME\",
        \"eventsource\": 0,
        \"status\": 0,
        \"esc_period\": \"1h\",
        \"def_shortdata\": \"{TRIGGER.NAME}: {TRIGGER.STATUS}\",
        \"def_longdata\": \"{TRIGGER.NAME}: {TRIGGER.STATUS}\r\nLast value: {ITEM.LASTVALUE}\r\n\r\n{TRIGGER.URL}\",
        \"filter\": {
            \"evaltype\": 0,
            \"conditions\": [
$(cat /tmp/FILTER_CONDITIONS.txt)
            ]
        },
        \"operations\": [
            {
                \"operationtype\": 0,
                \"esc_period\": \"0\",
                \"esc_step_from\": 1,
                \"esc_step_to\": 1,
                \"evaltype\": 0,
                \"opmessage_usr\": [
$(cat /tmp/OPMESSAGE_USR.txt)                
                ],
                \"opmessage\": {
                    \"default_msg\": 1,
                    \"mediatypeid\": \"1\"
                }
            }
        ],
        \"recovery_operations\": [
            {
                \"operationtype\": \"11\",
                \"opmessage\": {
                    \"default_msg\": 1
                }
            }    
        ]
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url
echo

else
echo no emails found at all:
cat $ACTIONNAME.emails.txt 
fi

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

