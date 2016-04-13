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
#################################
cd /mls
#Download meta and picture from windows
#
#wget -r ftp://$USER:$PASSWD@$HOST/ >/dev/null 
#Get number of resi
time=`date +'%Y%m%d%H%M'`
resi_count=`wc -l $residata|awk '{print $1}'`
condo_count=`wc -l $condodata|awk '{print $1}'`
resi_pic_count=`ls $resipic |wc -l`
condo_pic_count=`ls $condopic |wc -l`

echo "TIME:$time,RESI:$resi_count,RESI_PIC:$resi_pic_count,CONDO:$condo_count,CONDO_PIC:$condo_pic_count"



#Delete Resi on Windows
echo "TIME:$time,Delete Resi Data and Picture"
#lftp -u $USER,$PASSWD $HOST -e "rm -r resi;mkdir resi/picture;mkdir resi/data;exit"
#Delete Condo on Windows
echo "TIME:$time,Delete Condo Data and Picture"
#lftp -u $USER,$PASSWD $HOST -e "rm -r condo;mkdir condo/picture;mkdir condo/data;exit"

################################################
#Load CSV into Table

sudo chown mysql:mysql $residata
sudo chown mysql:mysql $condodata
echo "copy $residata,$condodata to /tmp"
sudo cp $residata /tmp/resi.txt
sudo cp $condodata /tmp/condo.txt
echo "Load data into tables......."

loadcondo="LOAD DATA INFILE '/tmp/condo.txt'  ignore INTO TABLE condo   FIELDS TERMINATED BY '|' ;"
loadresi="LOAD DATA INFILE '/tmp/resi.txt'  ignore INTO TABLE resi   FIELDS TERMINATED BY '|' ;"

/usr/bin/mysql -u root -p19701029 mls -e "$loadcondo"
/usr/bin/mysql -u root -p19701029 mls -e "$loadresi"

###############################################

# Add picture to mirror dir
echo "Copy Incremental Picture to Mirror dir"
#cp -r $homedir/resi/ /mls/mirror/
#cp -r $homedir/condo/ /mls/mirror/

########################################################
#Reconsile Active Listing
#Get List of Active from Table
if [ -s $homedir/resi/data/avail.txt ] 
then
	echo "Reconsile Resi Active vs Unavailable Listing"
	mysql -u root -p19701029 -N -B mls -e 'select ml_num from resi' >/tmp/resi_mls
	sed -e 's///g' $homedir/resi/data/avail.txt >>/tmp/resi_mls
	sort /tmp/resi_mls |uniq -c|grep "1 "|awk '{print $2}' | while read line
	do
	sql="update resi set status='U' where ml_num='$line'"
	echo "Set  $line as unavailable"
	mysql -u root -p19701029 -N -B mls -e "$sql"

	done

fi


if [ -s $homedir/condo/data/avail.txt ]
then
	echo "Reconsile Resi Active vs Unavailable Listing"
	mysql -u root -p19701029 -N -B mls -e 'select ml_num from condo' >/tmp/condo_mls
	sed -e 's///g' $homedir/condo/data/avail.txt >>/tmp/condo_mls
	sort /tmp/condo_mls |uniq -c|grep "1 "|awk '{print $2}'| while read line
	do
        sql="update condo set status='U' where ml_num='$line'"
        echo "Set  $line as unavailable"
        mysql -u root -p19701029 -N -B mls -e "$sql"


	done

fi

#Transfer Picture to MapleCity

#Load Data Table

