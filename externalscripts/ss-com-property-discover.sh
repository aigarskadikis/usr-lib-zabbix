#!/bin/bash

# each page contains multiple msg files
# that is why we need to create an array to put all page (msg IDs) into
declare -a array

nr=0 #start check from page 0
httpcode=200 #reset the status code as OK

# this while loop is only to count how many pages needs to analysed
while [ "$httpcode" -eq "200" ]
do

# increase page number
nr=$((nr+1))

# set full url link. remove the forwardslash in the end of argument if exists
url=$(echo "$1" | sed "s/\/$//")/page$nr.html

# check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$httpcode" -eq "200" ]; then
array[nr]=$(curl -s "$url" | tr -cd '[:print:]' | sed "s|<tr|\n<tr|g;s|<\/tr>|\n|g" |\
grep "id..tr_[0-9]" | sed "s|<td|\n<td|g" | sed "1~10d" | sed "1~9d" | sed "2~8d" | sed "s|<br>|, |g" |\
sed "s|^.*\/msg\/|https:\/\/www.ss.com\/msg\/|g;s|\.html..id.*$|\.html|g" | sed "s/<[^>]*>//g" |\
sed "s|^|\"|g;s|$|\"|g" |\
sed ': loop;
i {\"{#URL}\":
a ,
n;
i \"{#PLACE}\":
a ,
n;
i \"{#ROOMS}\":
a ,
n;
i \"{#SQM}\":
a ,
n;
i \"{#FLOOR}\":
a ,
n;
i \"{#TYPE}\":
a ,
n;
i \"{#PRICE}\":
a },
n;
b loop' |\
tr -cd "[:print:]" | sed 's/\\/\\\\/g')
else
nr=$((nr-1))
fi

done

# output all array elements, remove new line characters
# convert output to JSON format for Zabbix LLD trapper item
echo "${array[@]}" | tr -cd '[:print:]' | sed "s/^/{\"data\":[/;s/,$/]}/" 

# install additional user
# groupadd ss.com
# useradd -s /sbin/nologin -g ss.com ss.com
# usermod -a -G zabbix ss.com
# grep ss.com /etc/passwd
# id ss.com
# chmod -R 770 /usr/lib/zabbix/externalscripts/*

# ser global cronjob
# */15 * * * * ss.com cd /usr/lib/zabbix/externalscripts && ./ss-com-deliver-json.sh "ss.com flats hand over" https://www.ss.com/en/real-estate/flats/riga/all/hand_over /dev/shm
# 47 * * * * ss.com cd /usr/lib/zabbix/externalscripts && ./ss-com-deliver-json.sh "ss.com flats sell" https://www.ss.com/en/real-estate/flats/riga/all/sell/ /dev/shm





