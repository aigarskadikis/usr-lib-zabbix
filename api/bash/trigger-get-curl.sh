#!/bin/bash

# usage
# ./trigger-get-curl.sh Admin zabbix "Zabbix agent on {HOST.NAME} is unreachable for 5 minutes"

USER=$1
PASS=$2
API='http://localhost/zabbix/api_jsonrpc.php'
DESCRIPTION=$3

# authenticate with Zabbix API
authenticate() {
echo `curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${USER}"\",\"password\":\""${PASS}"\"},\"auth\": null,\"id\":0}" $API`
}

# show authorization token
AUTH_TOKEN=`echo $(authenticate)|grep -oP '([0-9a-z]{32})'`
echo $AUTH_TOKEN

# trigger get
triggerget() {
echo `curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\":\"2.0\",\"method\":\"trigger.get\",\"params\":{\"output\":\"[triggerid]\",\"expandDescription\":\"true\",\"filter\":{\"description\":\"$DESCRIPTION\"}},\"auth\":\""${AUTH_TOKEN}"\",\"id\":0}" $API`
}

RESPONSE=$(triggerget)

echo $RESPONSE

exit 0
