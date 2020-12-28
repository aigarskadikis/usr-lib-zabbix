#!/bin/bash

#maximum count blogger can contain per one sitemap view is 50 posts. that is why we need to create array to put all post ids inside 
declare -a array

nr=-49 #start check from page 0
count=1 #loop will continue while there is at least one post in sitemap
i=0 #array counter. all entries which contains one link goes inside array

#loop starts because we definet so in previous step
while [ "$count" -gt "0" ]
do

#how many posts should check per one view
nr=$((nr+50))

#set up full url link
url="https://$1/feeds/posts/default/-/$(echo "$2"|sed "s/ /%20/g")/?atom.xml?redirect=false&start-index=$nr&max-results=50"
#uncoment for debuging
#echo "$url"

#check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

#detect is there any entries in this sitemap
count=$(curl -s "$url" | sed "s/<entry>/\n<entry>/g" | grep "entry" | wc -l)
#echo "total count of entries $count"
#if there is some entries
if [ "$count" -gt "0" ]; then

#put all founded entries in array
allentries=$(curl -s "$url" | xmllint --xpath "//*[local-name()='feed']/*[local-name()='entry']" - | sed "s/<entry/\n\n<entry/g" )
#start a loop to work with single entry
#reset active entry
active=1

#loop starts
while [ "$active" -le "$count" ]
do
#echo "active entry: $active"
oneentry=$(echo "$allentries" |awk "/<entry>/{i++}i==$active{print; exit}" | sed "s/</\n</g" )
postid=$(echo "$oneentry" | egrep -o "post\-[0-9]+" | egrep -o "[0-9]+" )

#extract content just exactly between title tags
title=$(echo "$oneentry" | grep "<title" | sed "s/<title type=.text.>//")
#title=$(echo "$oneentry" | xmllint --xpath "//*[local-name()='entry']/*[local-name()='title']" -)

publicurl=$(echo "$oneentry" | grep "<link rel=\"alternate\"" | egrep -o "https.*\.html")

#echo "$oneentry" 

#echo "PostID=$postid"
#echo "Title=$title"
#echo "PublicURL=$publicurl"
#echo "Links on page:"

#check if this content have at least on link 
linkcount=$(echo "$oneentry" | sed "s/<content type=.html.>/<content>\n/g" | sed '1,/<content/d;/<\/content/,$d' | \
sed "s/\d034\|\d039/\n/g" | grep "^http.*://" | sed "s/\\\/\\\\\\\/g" | wc -l)

if [ "$linkcount" -gt "0" ]; then

i=$((i+1))
#format part of JSON without {data:[]}
array[i]=$(echo "$oneentry" | sed "s/<content type=.html.>/<content>\n/g" | sed '1,/<content/d;/<\/content/,$d' | \
sed "s/http/\nhttp/g;s/ftp:/\nftp:/g;s/\&lt;/\n/g" | grep -E -o "^[fht]+p(s)?:\/\/[a-zA-Z0-9\.\/_:?=&-]+" | sort | uniq | sed "s/\\\/\\\\\\\/g" | sed "s/\&amp;/\&/g" | \
sed "s|^|{\"{#ID}\":\"$postid\",\"{#TITLE}\":\"$title\",\"{#URL}\":\"$publicurl\",\"{#LINK}\":\"|" | \
sed "s/$/\"},/")

#for debuging
#echo "${array[i]}"

#echo
fi

active=$((active+1))
done

fi

done


#check if the result is empty
#echo "${array[@]}" | grep 
result=$(echo "${array[@]}" | grep -v "^$" | wc -l)
#echo $result
if [ "$result" -gt "0" ]; then
echo "${array[@]}" | sort | uniq | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"
else
echo "{\"data\":[]}"
fi
