#!/bin/bash
IFS=':, ' read -r -a array <<< "$1"
idx=0
echo {\"data\":[
while [ -n "${array[$idx]}" ]; do
echo -n \{\"{#REMOTE_IP}\":\""${array[$idx]}"\",\"{#REMOTE_PORT}\":\""${array[$idx+1]}"\"\}
let idx=$idx+2
[ -n "${array[idx]}" ] && echo "," || echo
done
echo ]}
exit
