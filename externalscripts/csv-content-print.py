#!/usr/bin/env python
import csv

file = open("hostlist.csv",'rb')
reader = csv.DictReader( file )

for line in reader:
 print line

file.close()
