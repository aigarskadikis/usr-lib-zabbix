#!/bin/bash
curl -s "https://$1/feeds/posts/default/$2?alt=json"|jq -r '.entry|.content|."$t"'|tidy -xml 2>&1|grep "^line.*Error:"|wc -l

