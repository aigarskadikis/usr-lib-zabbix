#!/bin/bash

echo '{"data":['

echo "$(
for p in $( \
sudo grep ^VmRSS /proc/*/status | \
grep -E '[0-9]{4} kB' | \
sed 's|.status.*$||' | \
grep -Eo '[0-9]+' \
); do if [ -f "/proc/$p/environ" -a -f "/proc/$p/comm" ]; 
then

echo "
{
\"{#BIN}\":\"$(sudo cat /proc/$p/comm)\",
\"{#PID}\":\"$p\",
\"{#HOSTNAME}\":\"$(sudo cat /proc/$p/environ | tr '\0' '\n' | grep ^HOSTNAME= | sed "s|^.*=||")\",
\"{#USER}\":\"$(sudo cat /proc/$p/environ | tr '\0' '\n' | grep ^USER= | sed "s|^.*=||;s|\/|\\\/|g")\",
\"{#ENV}\":\"$(sudo md5sum /proc/$p/environ|sed 's| .*$||')\"
},
"

fi
done
)" 

echo '{
"{#BIN}":"dummy",
"{#PID}":"dummy",
"{#HOSTNAME}":"dummy",
"{#USER}":"dummy",
"{#ENV}":"dummy"
}]}'
