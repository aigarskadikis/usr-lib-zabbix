#!/bin/bash

itemurl=https://www.salidzini.lv/cena?q=$(echo $1 | sed 's/\./\+/g')
#echo $itemurl

cenalinks=$(wget -qO- $itemurl | \
grep -m1 -B1 'price.\s.*content' | \
sed -e "s/<div/\n<div/g;s/<span/\n<span/g;s/<a/\n<a/g" | \
grep -m1 -B7 'price.\s.*content' | \
grep 'itemid\|price.\s' | \
sed 's/\d034/\n/g' | \
sed 's/\//https:\/\/www\.salidzini\.lv\//g' | \
grep '[0-9\.]' | sort | sed 's/\&amp;/\&/g')

#echo "$cenalinks"

#put the price in first variable
cena=$(echo "$cenalinks" | head -1)

#put the redirect link
redirect=$(echo "$cenalinks" | tail -1)

#show the price
echo $cena

#look for real link
url=$(curl -sS "$redirect" | grep 'window.location' | sed 's/\d034/\n/g' | grep '^http')

#show exactly direct link where this item belongs
echo $url

