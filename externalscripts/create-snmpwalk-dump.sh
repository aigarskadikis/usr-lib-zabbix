#/bin/bash
destination=/home/zabbix/snmpwalk.dump

if [ ! -d "$destination" ]; then
mkdir -p "$destination"
fi

objectid=$(snmpget -v2c -c $1 $2 .1.3.6.1.2.1.1.2.0 -Onv | sed "s|^.*.1.3.6.1.4.1|1.3.6.1.4.1|")

if [ ! -d "$destination/$objectid" ]; then
mkdir -p "$destination/$objectid"
fi


if [ ! -f "$destination/$objectid/numeric-$2.log" ]; then
/usr/bin/snmpwalk -v2c -c $1 $2 -On . > "$destination/$objectid/numeric-$2.log"
fi

if [ ! -f "$destination/$objectid/translated-$2.log" ]; then
/usr/bin/snmpwalk -v2c -c $1 $2 -OfT . > "$destination/$objectid/translated-$2.log"
fi
