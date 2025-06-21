#!/bin/bash
echo "===================" | tee --append /tmp/sleep.log
date | tee --append /tmp/sleep.log
sleep $1
echo $1 | tee --append /tmp/sleep.log
date | tee --append /tmp/sleep.log
echo "===================" | tee --append /tmp/sleep.log
cat /tmp/sleep.log
