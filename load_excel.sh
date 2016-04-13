#!/bin/bash

filedir="/home/ubuntu"
sudo rm -f /tmp/mls_hist.csv
cd $filedir

#convert file to csv
file_all="All-HP.xlsx"
file_detach="Detach-HP.xlsx"
file_condo="Condo-HP.xlsx"

#sudo ssconvert $file_all /tmp/mhall.csv
#sudo ssconvert $file_detach /tmp/mhdetach.csv
#sudo ssconvert $file_condo /tmp/mhcondo.csv

loadsql(){

sudo chown mysql:mysql /tmp/mls_hist.csv
#
sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db"


#echo $sqlcmd -e "delete from h_mls_hist;"
sqls="delete from h_mls_hist;"
$sqlcmd -e "$sqls"
#mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db  -e "delete from h_mls_hist;"

sql="LOAD DATA  LOCAL  infile '/tmp/mls_hist.csv' INTO TABLE h_mls_hist fields terminated BY '|'; "

echo $sqlcmd -e "$sql"
$sqlcmd -e "$sql"

}

parse(){

filename=$1
#Data Type
type=$2
echo "Load file $1 into table with type $type"
IFS=","
tail -n +10 $filename | while read sdate sales dollor avg_price new_list snlr active_list moi avg_dom avg_splp

do
mydate=`echo $sdate | sed 's/"//g'|sed "s/'//"|sed 's/ 0/ 200/'|sed 's/ 1/ 201/'|sed 's/ 9/ 199/'`
#read mon year <<< "$mydate"
#date1=`echo "$mydate" | sed 's/ / 1 /'`
date1=`echo "$mydate" | sed 's/ / 1 /'`
newdate=`date -d "$date1" "+%Y-%m-%d"`
echo $newdate"|"$sales"|"$dollor"|"$avg_price"|"$new_list"|"$snlr"|"$active_list"|"$moi"|"$avg_dom"|"$avg_splp"|"$type >> /tmp/mls_hist.csv

done

}

parse /tmp/mhall.csv all
parse /tmp/mhdetach.csv detach
parse /tmp/mhcondo.csv condo


unset IFS

loadsql
