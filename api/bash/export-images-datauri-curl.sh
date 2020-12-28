#!/bin/bash
# description: Remove unreachable host from Zabbix

USER=$1
PASS=$2
API='http://localhost/zabbix/api_jsonrpc.php'
IMAGE_NAME=$3

# Authenticate with Zabbix API

authenticate() {
echo `curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${USER}"\",\"password\":\""${PASS}"\"},\"auth\": null,\"id\":0}" $API`
}

AUTH_TOKEN=`echo $(authenticate)|grep -oP '([0-9a-z]{32})'`
echo $AUTH_TOKEN
# Get HostId:


curl -s -H 'Content-Type: application/json-rpc' -d "{
    \"jsonrpc\": \"2.0\",
    \"method\": \"configuration.export\",
    \"params\": {
        \"options\": {
            \"images\": [
                $IMAGE_NAME
            ]
        },
        \"format\": \"xml\"
    },
    \"auth\": \""${AUTH_TOKEN}"\",
    \"id\": 1
}" $API



exit 0

