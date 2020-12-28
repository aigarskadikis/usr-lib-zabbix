#!/bin/bash
# description: Remove unreachable host from Zabbix

USER=$1
PASS=$2
API='http://localhost/zabbix/api_jsonrpc.php'
HOST_NAME=$1

# Authenticate with Zabbix API

authenticate() {
echo `curl -s -H  'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"user.login\",\"params\":{\"user\":\""${USER}"\",\"password\":\""${PASS}"\"},\"auth\": null,\"id\":0}" $API`
}

AUTH_TOKEN=`echo $(authenticate)|grep -oP '([0-9a-z]{32})'`
echo $AUTH_TOKEN
# Get HostId:

gethostid() {
echo `curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"host.get\",\"params\":{\"output\":[\"hostid\"],\"filter\":{\"host\":[\"$HOST_NAME\"]}},\"auth\":\""${AUTH_TOKEN}"\",\"id\":0}" $API`
}

HOST_ID=`echo $(gethostid)| grep -oP '[0-9]{5,15}'`
echo $HOST_ID
# Remove Host

remove_host() {
echo `curl -s -H 'Content-Type: application/json-rpc' -d "{\"jsonrpc\": \"2.0\",\"method\":\"host.delete\",\"params\":[\"${HOST_ID}\"],\"auth\":\""${AUTH_TOKEN}"\",\"id\":0}" $API`
}
RESPONSE=$(remove_host)

exit 0

