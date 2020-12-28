#!/usr/bin/env python

tagged_events=[1,2,3,4]
string=''
for elem in tagged_events[:-1]:
  string+=str(elem)+','

string+=str(tagged_events[-1])
  
print string

