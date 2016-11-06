#!/bin/bash

backupdir="/disk2/sqlbackup/"
cd $backupdir
bdate=`date +%Y%m%d`
#Backup DB
mysqldump -u root -p19701029 --all-databases >mapledb.$bdate
rm mapledb.$bdate.gz
gzip mapledb.$bdate

find ./ -type f -mtime +90 -exec rm -f {} +
