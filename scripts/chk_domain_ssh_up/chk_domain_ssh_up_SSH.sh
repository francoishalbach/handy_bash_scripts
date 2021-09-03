#!/bin/bash

DOM_FILE="all_hosts"
DATE=$(date "+%Y%m%d%T")
GOOD_LOGFILE="good_doms_"$DATE
BAD_LOGFILE="bad_doms_"$DATE
touch $GOOD_LOGFILE $BAD_LOGFILE

for DOMAIN in $( < $DOM_FILE ) ; do
    ssh -n -o PasswordAuthentication=no -oStrictHostKeyChecking=no -o ConnectTimeout=5 $DOMAIN hostname
    if [ $? == 0 ] ; then echo $DOMAIN >> $GOOD_LOGFILE 2>&1; else echo $DOMAIN >> $BAD_LOGFILE 2>&1; fi
done
