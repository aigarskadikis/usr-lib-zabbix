#!/bin/bash
find $3 -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
php max_perf.php $1 $2 $TEMPLATE
} done
