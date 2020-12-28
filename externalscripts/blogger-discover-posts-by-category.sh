#!/bin/bash

curl -s "https://$1/feeds/posts/default/-/$(echo "$2"|sed "s/ /%20/g")?alt=json-in-script&max-results=100" |\
sed "s/gdata.io.handleScriptLoaded(//;s/);$//" |\
jq '.["feed"] | .["entry"] | .[] | (.link[] | select(.rel == "alternate").href),(.link[] | select(.rel == "alternate").title),.id."$t"' |\
sed "s/tag:blogger.com,1999:blog-.*.post-//g" |\
sed ': loop;
i {\"{#URL}\":
a ,
n;
i \"{#TITLE}\":
a ,
n;
i \"{#POST}\":
a },
n;
b loop' |\
tr -cd "[:print:]" |\
sed "s/[ \t]*$//" |\
sed "s/^/{\"data\":[/;s/,$/]}/"

