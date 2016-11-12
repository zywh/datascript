#!/bin/bash

sqlfile="/tmp/crea_pic_num.txt"
crea_pic_prefix="/disk2/crea"
sudo rm $sqlfile


function scan_pic  {
province=$1
cd $crea_pic_prefix/$province
echo "$crea_pic_prefix/$province"

#du -a | cut -d/ -f2 | sort | uniq -c >/tmp/crea_pic_count.raw
du -a |grep jpg| cut -d/ -f2 | uniq -c >/tmp/crea_pic_count.raw

cat /tmp/crea_pic_count.raw | while read line
do
set $line
count=$1
ml_num=`echo $2 | sed 's/Photo//'`
#((count = count - 1))
if [ -n "$ml_num" ]
then
echo $ml_num","$count >>$sqlfile

fi
done

}


scan_pic  Ontario "Ontario"
scan_pic  BritishColumbia "British Columbia"
scan_pic  Alberta "Alberta"
scan_pic  NewfoundlandLabrador 'Newfoundland & Labrador'
scan_pic  PrinceEdwardIsland 'Prince Edward Island'
scan_pic  NewBrunswick 'New Brunswick'
scan_pic  NovaScotia 'Nova Scotia'


sudo chown mysql:mysql $sqlfile
#sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
loadsql="LOAD DATA INFILE '"$sqlfile"'  replace INTO TABLE pic_num   FIELDS TERMINATED BY ',' ;"

/usr/bin/mysql -u root -p19701029 mls -e "$loadsql"


