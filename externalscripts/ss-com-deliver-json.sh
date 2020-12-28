#!/bin/bash

# $1 = "ss.com flats hand over"
# $2 = https://www.ss.com/lv/real-estate/flats/riga/all/hand_over
# $3 = /dev/shm

jobid=$(echo $2 | sed "s/\/$//" | sed "s/^.*\///g")
out=$3/zbx.ss.com.$jobid.json

# set temp file monitoring in zabbix. will check date and size
/usr/bin/zabbix_sender -z 127.0.0.1 -s "$1" -k files.to.monitor -o $(echo "{\"data\":[{\"{#ZBX.SS.COM.TEMP}\":\"$out\"}]}")

# fetch the information
cd /usr/lib/zabbix/externalscripts
./ss-com-property-discover.sh $2 > $out

# check if the file is valid json
jq . $out > /dev/null
/usr/bin/zabbix_sender -z 127.0.0.1 -s "$1" -k json.error -o $?

jq . $out > /dev/null
if [ $? -eq 0 ]; then

# send how many items are active 
/usr/bin/zabbix_sender -z 127.0.0.1 -s "$1" -k msg.count -o $(jq . $out | grep -c "{#URL}")

# escape the backslash
sed -i 's/\\/\\\\/g' $out

# escape the double quotes
sed -i 's|\"|\\\"|g' $out

# set destination (hostname and item) where this json should be delivered
sed -i "s|^|\"$1\" discover.ss.items\ \"|;s|$|\"|" $out

# send the json to server
zabbix_sender -z 127.0.0.1 -i $out

fi
