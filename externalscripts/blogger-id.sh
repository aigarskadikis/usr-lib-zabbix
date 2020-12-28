#!/bin/bash
curl -s "https://$1/feeds/posts/default/?atom.xml?redirect=false&start-index=1&max-results=0" | egrep -o "\/feeds\/[0-9]+"|egrep -o "[0-9]+"
