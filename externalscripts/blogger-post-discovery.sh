#!/bin/bash

#each page contains multiple msg files
#that is why we need to create array to put all page msh into
declare -a array

BLOG=$1
#define endpoint for url for example if the ir is
#https://catonrug.blogspot.com/feeds/posts/default/?atom.xml?redirect=false&start-index=1&max-results=50
#then the endpoint is "multimedia"
endpoint="https://$1/feeds/posts/default/?atom.xml?redirect=false&max-results=1&start-index="

arr=0 # array position
count_of_elements=1 # count the found posts
nr=0 # -49+50=1 which means to start from post 1

# while the atom.xml file contans at least 1 record, continue to gather data
while [ "$count_of_elements" -ne "0" ]
do

# analize next 50 posts
nr=$((nr+1))

# switch to next slot in array
arr=$((arr+1))

# set full url link to analyze
url=$(echo "$endpoint$nr")
#echo $url

# check if url is healthy
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$count_of_elements" -ne "0" ]; then
ENTRY=$(curl -ksL "$url")
URL=$(echo "$ENTRY" | grep -Eo -m1 "http[a-zA-Z0-9\/:.-]+#comment-form" | sed "s|#.*$||")
if [ ! -z "$URL" ]; then
BLOG_AND_POST=$(echo "$ENTRY" | grep -Eo "blog-[0-9]+\.post-[0-9]+")
BLOGID=$(echo "$BLOG_AND_POST" | grep -Eo "blog-[0-9]+" | grep -Eo "[0-9]+")
POSTID=$(echo "$BLOG_AND_POST" | grep -Eo "\.post-[0-9]+" | grep -Eo "[0-9]+")

CATEGORIES=$(curl -skL "https://$BLOG/feeds/posts/default/$POSTID?alt=json" | jq '.entry.category[].term' | sed "s|^|{\"{#CAT}\":|;s|$|},|" | tr -cd '[:print:]' | sed "s|,$|]|;s|^|[|")
ELEMENT=$(echo "{\"{#BLOG}\":\"$BLOG\",\"{#BLOGID}\":\"$BLOGID\",\"{#POSTID}\":\"$POSTID\",\"{#URL}\":\"$URL\",\"{#CATEGORIES}\":$CATEGORIES},")
array[arr]=$ELEMENT
fi
count_of_elements=$(echo "$ENTRY" | grep -Eo "blog-[0-9]+\.post-[0-9]+" | wc -l)
#echo $count_of_elements
#echo "${array[arr]}" 
#else
#arr=$((arr-1))
fi

done

#output all array elements
#replace spaces with new line characters
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" | tr -cd '[:print:]' | sed "s/^/{\"data\":[/;s/,$/]}/" 

