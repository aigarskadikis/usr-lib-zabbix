#!/bin/bash

#remove the forwardshal of base link if exist
#every base link do not contain mesages, but need to do some modification for example
#base link: https://www.ss.com/lv/electronics/computers/printers-scanners-cartridges/printers/
# msg link: https://www.ss.com/msg/lv/electronics/computers/printers-scanners-cartridges/printers/kcgim.html
url=$(echo "$1" | sed "s/\/$//;s/ss.com\//ss.com\/msg\//;s/$/\/$2.html/")

#download content
content=$(curl -s "$url")

#extract price
price=$(echo "$content" | egrep -o "MSG_PRICE = [0-9\.]+" | egrep -o "[0-9\.]+")

#extract body
body=$(echo "$content" | sed "s/</\n</g" | awk '/msg_div_msg/{flag=1;next}/table/{flag=0}flag' |\
sed -e 's/<[^>]*>//g' | sed '/^\s*$/d' | sed "s/$/; /g") 
#tr -cd '[:print:]')

if [[ !  -z  $price  ]]; then
echo $price
else
echo 0
fi
echo $url
echo $body 

