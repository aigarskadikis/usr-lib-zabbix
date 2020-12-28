#!/bin/bash

#each page contains multiple msg files
#that is why we need to create array to put all page msh into
declare -a array

#define endpoint for url for example if the ir is
#https://www.ss.com/lv/electronics/computers/multimedia/
#then the endpoint is "multimedia"
endpoint=$(echo "$1" | sed "s/\/$//;s/^.*\///g")

nr=0 #start check from page 0
httpcode=200 #reset the status code as OK

#this while loop is only to count how many pages needs to analyse
while [ "$httpcode" -eq "200" ]
do

#increase page number
nr=$((nr+1))

#set full url link
#remove the forwardslash in the end of argument if exists
url=$(echo "$1" | sed "s/\/$//")/page$nr.html

#check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$httpcode" -eq "200" ]; then
array[nr]=$(curl -s "$url" | sed "s/<\/tr>/<\/tr>\n\n/g" | grep "input.*nowrap" | sed "s/^.*$endpoint\//{\"{#MSG}\":\"/g" | sed "s/\.html.>.*c=1>/\",\"{#PRICE}\":\"/g" | sed "s/[[:space:]].*$/\"},/g" | egrep "\"[0-9\.]+\"")
#echo "${array[nr]}"
else
nr=$((nr-1))
fi

done

#output all array elements
#replace spaces with new line characters
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" | tr -cd '[:print:]' | sed "s/^/{\"data\":[/;s/,$/]}/"

