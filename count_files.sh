#!/bin/bash
cd /mls/treb
rm /tmp/pic_num.sql
#du -a | cut -d/ -f2 | sort | uniq -c >/tmp/test1
cat /tmp/test1 | while read line
do
set $line
count=$1
ml_num=`echo $2 | sed 's/Photo//'`
((count = count - 1))
echo $count $ml_num
if [ -n "$ml_num" ]
then
echo "update h_house set pic_num='"$count"' where ml_num='"$ml_num"';" >>/tmp/pic_num.sql

fi
done

sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "

`$sqlcmd < /tmp/pic_num.sql`


