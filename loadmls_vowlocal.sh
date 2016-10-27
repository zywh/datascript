#!/bin/bash

########################
#Global  Parameter
########################
HOST='172.30.0.108'
PASSWD='19701029'
USER='mls'
homedir="/mls/172.30.0.108"
residata="$homedir/resi/data/data.txt"
resipic="$homedir/resi/picture"
condodata="$homedir/condo/data/data.txt"
condopic="$homedir/condo/picture"

vowresidata="$homedir/vowresi/data/data.txt"
vowresipic="$homedir/vowresi/picture"
vowcondodata="$homedir/vowcondo/data/data.txt"
vowcondopic="$homedir/vowcondo/picture"

mlslog="/home/ubuntu/log/mlslog.txt"

#load_vow.sh

#################################
cd /mls


stats="/tmp/stats"

#Get number of resi
time=`date +'%Y%m%d%H%M'`
resi_count=`wc -l $vowresidata|awk '{print $1}'`
condo_count=`wc -l $vowcondodata|awk '{print $1}'`
resi_pic_count=`ls $vowresipic |wc -l`
condo_pic_count=`ls $vowcondopic |wc -l`

echo "TIME:$time,VOWRESI:$resi_count,VOWRESI_PIC:$resi_pic_count,VOWCONDO:$condo_count,VOWCONDO_PIC:$condo_pic_count" >>$mlslog
#Log stats 

#
#DEBUG

echo "u_resi:$resi_count" >$stats
echo "u_condo:$condo_count" >> $stats




################################################
#Load CSV into Table

sudo chown mysql:mysql $vowresidata
sudo chown mysql:mysql $vowcondodata
sudo chown mysql:mysql /tmp/idx.ml
echo "copy $vowresidata,$vowcondodata to /tmp"
sudo cp -p $vowresidata /tmp/resi.txt
sudo cp -p $vowcondodata /tmp/condo.txt
echo "Load data into tables......."

loadcondo="LOAD DATA INFILE '/tmp/condo.txt'  replace INTO TABLE vowcondo   FIELDS TERMINATED BY '|' ;"
loadresi="LOAD DATA INFILE '/tmp/resi.txt'  replace INTO TABLE vowresi   FIELDS TERMINATED BY '|' ;"
/usr/bin/mysql -u root -p19701029 mls -e "$loadcondo"
/usr/bin/mysql -u root -p19701029 mls -e "$loadresi"

#Load IDX all for compare with VOW data
load_idx="
delete from idx_mls;
LOAD DATA LOCAL INFILE '/tmp/idx.ml'  replace INTO TABLE idx_mls ;
"
sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
`$sqlcmd -e "$load_idx"`



echo "`date`: Complete Load resi and condo table" >>$mlslog


########################################################
#Reconsile Active Listing
#Get List of Active from Table

resi_active=`wc -l < $homedir/vowresi/data/avail.txt`
echo "t_resi:$resi_active" >>$stats

if [ -s $homedir/vowresi/data/avail.txt ] 
then
	echo "Reconsile Resi Active vs available Listing"
	mysql -u root -p19701029 -N -B mls -e 'select ml_num from vowresi' >/tmp/resi_mls
	cat $homedir/vowresi/data/avail.txt >>/tmp/resi_mls
	sort /tmp/resi_mls |uniq -c|grep "1 "|awk '{print $2}' | while read line
	do
	sql="delete from resi where ml_num='$line'"
	#echo "Set  $line as unavailable"
	mysql -u root -p19701029 -N -B mls -e "$sql"

	done

fi
resi_sold=`sort /tmp/resi_mls |uniq -c|grep "1 "|wc -l` 


condo_active=`wc -l < $homedir/vowcondo/data/avail.txt`
echo "t_condo:$condo_active" >>$stats

if [ -s $homedir/vowcondo/data/avail.txt ]
then
	echo "Reconsile condo Active vs available Listing"
	mysql -u root -p19701029 -N -B mls -e 'select ml_num from vowcondo' >/tmp/condo_mls
	cat $homedir/vowcondo/data/avail.txt >>/tmp/condo_mls
	sort /tmp/condo_mls |uniq -c|grep "1 "|awk '{print $2}'| while read line
	do
        sql="delete from vowcondo where ml_num='$line'"
        #echo "Set  $line as unavailable"
        mysql -u root -p19701029 -N -B mls -e "$sql"


	done

fi
condo_sold=`sort /tmp/condo_mls |uniq -c|grep "1 "|wc -l` 

# Load Picture and Data into MapleCity Website
#/home/ubuntu/script/picsync_vow.sh


