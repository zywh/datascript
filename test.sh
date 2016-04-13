#!/bin/bash

msql="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
mlslog="/home/ubuntu/log/mlslog.txt"
phpdir="/home/ubuntu/script/crea/phRETS/PHRetsForCREA-master"
sqlcmd="mysql -u root -p19701029 mls"
msql="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
csvfile="/tmp/crea.update"
active="/tmp/crea_active"
count=`wc -l < $csvfile`


echo $count
#Update CREA Stats
sql="
update h_stats set u_house = \"$count\" where date=CURRENT_DATE( );
"
`$msql -e "$sql"`



