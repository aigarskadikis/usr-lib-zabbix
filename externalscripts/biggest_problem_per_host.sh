#!/bin/bash

# select only hostid's where there are some problems
psql z40 -t -c "
SELECT DISTINCT hosts.hostid
FROM triggers
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE triggers.status=0
AND triggers.value=1
" | \
# remove empty lines
grep -v "^$" | \
# list the biggest problem per this host
while IFS= read -r hostid
do {
psql z40 -t -c "
SELECT
hosts.host,
CASE problem.severity
           WHEN 0 THEN 'NOT_CLASSIFIED'
           WHEN 1 THEN 'INFORMATION'
           WHEN 2 THEN 'WARNING'
           WHEN 3 THEN 'AVERAGE'
           WHEN 4 THEN 'HIGH'
           WHEN 5 THEN 'DISASTER'
       END AS highest_severity,
problem.name as problem_title
FROM problem
JOIN events ON (events.eventid=problem.eventid)
JOIN triggers ON (triggers.triggerid=events.objectid)
JOIN functions ON (functions.triggerid=triggers.triggerid)
JOIN items ON (items.itemid=functions.itemid)
JOIN hosts ON (hosts.hostid=items.hostid)
WHERE problem.source=0
AND events.source=0
AND hosts.hostid=$hostid
ORDER BY problem.severity DESC
LIMIT 1
"
} done
