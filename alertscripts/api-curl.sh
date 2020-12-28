#!/bin/bash
/usr/bin/curl -k -X POST "$1" -H "Content-Type: application/json" -H "cache-control: no-cache" -d "$2"
