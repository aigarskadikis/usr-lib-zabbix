#!/bin/bash
snmpwalk -v2c -c $4 $2:$3 -On $5 |\
sed "s|$5||g;s|^\.||g" |\
egrep -o "^[0-9]+" |\
sort|uniq |\
sed "s/^/{\"$1\":\"/" |\
sed "s/$/\"},/" |\
tr -cd "[:print:]" |\
sed "s/^/{\"data\":[/;s/,$/]}/"
