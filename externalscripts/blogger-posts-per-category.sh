#!/bin/bash

curl -s "https://$1/feeds/posts/default/-/$(echo "$2"|sed "s/ /%20/g")?alt=json-in-script&max-results=100" |\
sed "s/gdata.io.handleScriptLoaded(//;s/);$//" |\
jq '.["feed"] | .["entry"] | .[] | .id."$t"' |\
wc -l
