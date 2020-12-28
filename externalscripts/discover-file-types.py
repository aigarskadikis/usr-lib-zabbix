#!/usr/bin/env python
import os
import sys
import json

logdir = sys.argv[1]
extensions = sys.argv[2:]
data = []

for (logdir, _, files) in os.walk(logdir):
 for f in files:
  for extension in extensions:
   if f.endswith(extension):
    path = os.path.join(logdir,f)
    data.append({'{#FULLFILEPATH}':path})
    jsondata = json.dumps(data)

print json.dumps({"data": data})

