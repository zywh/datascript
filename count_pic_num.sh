#!/bin/bash

sqlfile="/tmp/pic_num.txt"
treb_count_sql="/tmp/treb_pic_num.txt"
cd /mls/treb
sudo rm $sqlfile
du -a |grep jpeg| cut -d/ -f2 | uniq -c >/tmp/treb_pic_count.raw
cat /tmp/treb_pic_count.raw | while read line
do
set $line
count=$1
ml_num=`echo $2 | sed 's/Photo//'`
if [ -n "$ml_num" ]
then
echo "$ml_num,$count" >>$sqlfile

fi
done

sudo chown mysql:mysql $sqlfile
loadsql="
DELETE FROM pic_num;
LOAD DATA INFILE '"$sqlfile"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;
LOAD DATA INFILE '"$treb_count_sql"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;
"

/usr/bin/mysql -u root -p19701029 mls -e "$loadsql"




