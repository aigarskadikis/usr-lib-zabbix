#!/bin/bash
curl -s "https://$1/feeds/posts/default/$2?alt=json" | jq -r .entry.category[].term | grep -ce "^i$\|^e$"
