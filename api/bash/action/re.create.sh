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

# create an empty filter conditions. this is required to add multiple hosts in pool
FILTER_CONDITIONS=""

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

# only if the hostid has been found, then include it in pool
if [ ! -z $HOST_ID_TO_INCLUE ]; then
echo "$HOST_ID_TO_INCLUE"
FILTER_CONDITIONS+="{\"conditiontype\":1,\"operator\":0,\"value\":\"$HOST_ID_TO_INCLUE\"},"
echo "$FILTER_CONDITIONS" | sed "s|.$||" > /tmp/FILTER_CONDITIONS.txt
fi

} done
cat /tmp/FILTER_CONDITIONS.txt

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
        \"esc_period\": \"2m\",
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
                \"esc_period\": \"0s\",
                \"esc_step_from\": 1,
                \"esc_step_to\": 2,
                \"evaltype\": 0,
                \"opmessage_grp\": [
                    {
                        \"usrgrpid\": \"7\"
                    }
                ],
                \"opmessage\": {
                    \"default_msg\": 1,
                    \"mediatypeid\": \"1\"
                }
            },
            {
                \"operationtype\": 1,
                \"esc_step_from\": 3,
                \"esc_step_to\": 4,
                \"evaltype\": 0,
                \"opconditions\": [
                    {
                        \"conditiontype\": 14,
                        \"operator\": 0,
                        \"value\": \"0\"
                    }
                ],
                \"opcommand_grp\": [
                    {
                        \"groupid\": \"2\"
                    }
                ],
                \"opcommand\": {
                    \"type\": 4,
                    \"scriptid\": \"3\"
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
        ],
        \"acknowledge_operations\": [
            {
                \"operationtype\": \"12\",
                \"opmessage\": {
                    \"message\": \"Custom acknowledge operation message body\",
                    \"subject\": \"Custom acknowledge operation message subject\"
                }
            }
        ]
    },
    \"auth\": \"$auth\",
    \"id\": 1
}
" $url

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

