#!/bin/bash

treb_count_sql="/tmp/treb_pic_num.txt"
crea_count_sql="/tmp/crea_pic_num.txt"
#get crea pic count
/home/ubuntu/script/count_crea_pic_num.sh
cd /mls/treb
sudo rm $treb_count_sql
du -a |grep jpeg| cut -d/ -f2 | uniq -c >/tmp/treb_pic_count.raw
cat /tmp/treb_pic_count.raw | while read line
do
set $line
count=$1
ml_num=`echo $2 | sed 's/Photo//'`
if [ -n "$ml_num" ]
then
echo "$ml_num,$count" >>$treb_count_sql

fi
done

sudo chown mysql:mysql $treb_count_sql
loadsql="
DELETE FROM pic_num;
LOAD DATA INFILE '"$treb_count_sql"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;
LOAD DATA INFILE '"$crea_count_sql"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;
"

/usr/bin/mysql -u root -p19701029 mls -e "$loadsql"




