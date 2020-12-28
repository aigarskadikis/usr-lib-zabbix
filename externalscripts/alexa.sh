#!/bin/bash
curl -s https://www.alexa.com/siteinfo/$1#trafficstats | \
grep 'global' | \
sed "s/,/\n/g" | \
grep 'global' | \
sed 's/:\|}/\n/g' | \
grep '^[0-9]\+'
