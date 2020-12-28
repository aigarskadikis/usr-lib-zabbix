#!/bin/bash
curl -s "https://rest.db.ripe.net/search.json?query-string=$1&flags=no-filtering&source=RIPE" | \
jq -r ".objects.object[2].attributes.attribute[1].value"
