#!/bin/bash
echo "$1" | sed "s/,/\n/g" | sed "s/^/{\"{#PATH}\":\"/;s/$/\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"
