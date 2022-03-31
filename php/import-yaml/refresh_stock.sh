#!/bin/bash
find $3 -type f -name '*.yaml' | \
while IFS= read -r TEMPLATE
do {
php delete_missing.php $1 $2 $TEMPLATE
} done
