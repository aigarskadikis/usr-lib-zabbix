#!/bin/bash
echo "$1" | grep "care.dlservice" > /dev/null
if [ "$?" -ne "0" ]; then
curl -o /dev/null -m 25 -s -w %{http_code} "$1"
else
wget --spider -S "$1" 2>&1 | grep -m1 "HTTP/" | awk '{print $2}'
fi
