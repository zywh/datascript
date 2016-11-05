#!/bin/bash

sqlfile="/tmp/pic_num.txt"
crea_count_sql="/tmp/crea_pic_num.txt"
cd /mls/treb
sudo rm $sqlfile
du -a |grep jpeg| cut -d/ -f2 | sort | uniq -c >/tmp/treb_pic_count.raw
exit 0
cat /tmp/treb_pic_count.raw | while read line
do
set $line
count=$1
ml_num=`echo $2 | sed 's/Photo//'`
#((count = count - 1))
if [ -n "$ml_num" ]
then
#echo "update h_house set pic_num='"$count"' where ml_num='"$ml_num"';" >>/tmp/pic_num.sql
echo $ml_num","$count >>$sqlfile

fi
done

sudo chown mysql:mysql $sqlfile
#sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
loadsql="
DELETE FROM pic_num;
LOAD DATA INFILE '"$sqlfile"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;
LOAD DATA INFILE '"$crea_count_sql"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;
"

/usr/bin/mysql -u root -p19701029 mls -e "$loadsql"




