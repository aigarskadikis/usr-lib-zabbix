#!/bin/bash

wget -S --spider --no-cookies --no-check-certificate \
--user-agent="Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E)" \
"$1" 2>&1 /dev/null | \
grep "$2" | \
grep -E -o "$3"

