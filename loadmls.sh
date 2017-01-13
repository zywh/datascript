#!/bin/bash

########################
#Global  Parameter
########################
source /home/ubuntu/script/script.env
PASSWD=$SQL_LOCAL_PASS
HOST='172.30.0.108'
USER='mls'
homedir="/mls/172.30.0.108"
residata="$homedir/resi/data/data.txt"
resipic="$homedir/resi/picture"
condodata="$homedir/condo/data/data.txt"
condopic="$homedir/condo/picture"
mlslog="/home/ubuntu/log/mlslog.txt"

#################################
cd /mls
#Download meta and picture from windows
#
echo "`date`: loadmls start FTP download file from windows" >>$mlslog


stats="/tmp/stats"

#wget -r ftp://$USER:$PASSWD@$HOST/ >/dev/null 
#Get number of resi
time=`date +'%Y%m%d%H%M'`
resi_count=`wc -l $residata|awk '{print $1}'`
condo_count=`wc -l $condodata|awk '{print $1}'`
resi_pic_count=`ls $resipic |wc -l`
condo_pic_count=`ls $condopic |wc -l`

echo "TIME:$time,RESI:$resi_count,RESI_PIC:$resi_pic_count,CONDO:$condo_count,CONDO_PIC:$condo_pic_count" >>$mlslog
#Log stats 

echo "u_resi:$resi_count" >$stats
echo "u_condo:$condo_count" >> $stats



#Delete Resi on Windows
echo "TIME:$time,Delete Resi Data and Picture"
lftp -u $USER,$PASSWD $HOST -e "rm -r resi;mkdir resi/picture;mkdir resi/data;exit"
#Delete Condo on Windows
echo "TIME:$time,Delete Condo Data and Picture"
lftp -u $USER,$PASSWD $HOST -e "rm -r condo;mkdir condo/picture;mkdir condo/data;exit"

################################################
#Load CSV into Table

sudo chown mysql:mysql $residata
sudo chown mysql:mysql $condodata
echo "copy $residata,$condodata to /tmp"
sudo cp -p $residata /tmp/resi.txt
sudo cp -p $condodata /tmp/condo.txt
echo "Load data into tables......."

#loadcondo="LOAD DATA INFILE '/tmp/condo.txt'  ignore INTO TABLE condo   FIELDS TERMINATED BY '|' ;"
loadcondo="LOAD DATA INFILE '/tmp/condo.txt'  replace INTO TABLE condo   FIELDS TERMINATED BY '|' ;"
#loadresi="LOAD DATA INFILE '/tmp/resi.txt'  ignore INTO TABLE resi   FIELDS TERMINATED BY '|' ;"
loadresi="LOAD DATA INFILE '/tmp/resi.txt'  replace INTO TABLE resi   FIELDS TERMINATED BY '|' ;"

/usr/bin/mysql -u root -p19701029 mls -e "$loadcondo"
/usr/bin/mysql -u root -p19701029 mls -e "$loadresi"

echo "`date`: Complete Load resi and condo table" >>$mlslog


########################################################
#Reconsile Active Listing
#Get List of Active from Table

resi_sold=`sort /tmp/resi_mls |uniq -c|grep "1 "|wc -l` 
resi_active=`wc -l < $homedir/resi/data/avail.txt`
echo "t_resi:$resi_active" >>$stats

if [ -s $homedir/resi/data/avail.txt ] 
then
	echo "Reconsile Resi Active vs available Listing"
	mysql -u root -p19701029 -N -B mls -e 'select ml_num from resi' >/tmp/resi_mls
	sed -e 's///g' $homedir/resi/data/avail.txt >>/tmp/resi_mls
	sort /tmp/resi_mls |uniq -c|grep "1 "|awk '{print $2}' | while read line
	do
	sql="delete from resi where ml_num='$line'"
	#echo "Set  $line as unavailable"
	mysql -u root -p19701029 -N -B mls -e "$sql"

	done

fi


condo_sold=`sort /tmp/condo_mls |uniq -c|grep "1 "|wc -l` 
condo_active=`wc -l < $homedir/condo/data/avail.txt`
echo "t_condo:$condo_active" >>$stats

if [ -s $homedir/condo/data/avail.txt ]
then
	echo "Reconsile condo Active vs available Listing"
	mysql -u root -p19701029 -N -B mls -e 'select ml_num from condo' >/tmp/condo_mls
	sed -e 's///g' $homedir/condo/data/avail.txt >>/tmp/condo_mls
	sort /tmp/condo_mls |uniq -c|grep "1 "|awk '{print $2}'| while read line
	do
        sql="delete from condo where ml_num='$line'"
        #echo "Set  $line as unavailable"
        mysql -u root -p19701029 -N -B mls -e "$sql"


	done

fi

# Load Picture and Data into MapleCity Website

/home/ubuntu/script/picsync.sh


