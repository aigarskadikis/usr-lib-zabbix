#!/bin/bash
CALL=$(find $2 -name $3)
MACRO=$1
COUNT=$(echo $CALL| xargs -n1 | wc -l)
printf "{\"data\":[\n"
echo $CALL | xargs -n1 | cut -d'>' -f2- | cut -d'<' -f1 | while read line; do \
        if [[ $COUNT > 1 ]];then
                printf "{\"{#$MACRO}\":\"$line\"},\n"
                COUNT=$(( COUNT - 1))
        elif [[ $COUNT = 1 ]]; then
                printf "{\"{#$MACRO}\":\"$line\"}\n"
fi;
done
printf "]}\n"

# discover all conf files in /etc direcotry
# ./discover-files.sh CONF /etc *.conf

# discover files in /var/log directory  containing this year in filename
# ./discover-log-files.sh F /var/log *$(date +%Y)*
