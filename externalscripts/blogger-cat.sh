#!/bin/bash
curl -s "https://$1/feeds/posts/default/?atom.xml?redirect=false&start-index=1&max-results=0" | sed "s/</\n</g"|grep "<category"|sed "s/<category term=/{\"{#CAT}\":/g;s/\/>/},/g"|tr -cd "[:print:]"|sed "s/^/{\"data\":[/;s/,$/]}/"

