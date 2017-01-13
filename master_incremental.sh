#!/bin/bash

source /home/ubuntu/script/script.env

#mlslog="/home/ubuntu/log/mlslog.txt"
#scriptdir="/home/ubuntu/script"

#check if it's running


pcount=`ps -aef|grep master_incremental|wc -l`;
echo $pcount

if [ $pcount -gt 3 ] 
then
echo "Program  is running.... exit"
exit 0
fi


echo "`date`: dowload VOW data and picture start" >>$mlslog

cd /home/ubuntu/script/treb
#load vow data and picture
echo "`date`: Start dowload VOW Data and Pictures" >>$mlslog
sudo php  download_vow_data.php 25 $VOW_USER $VOW_PASS
echo "`date`: End dowload VOW Data and Pictures" >>$mlslog


#generate TREB TN and MID
$scriptdir/generate_tn_incremental.sh

#Local VOW data into local resi and condo table
$scriptdir/loadmls_vowlocal_incremental.sh


#Update treb pic_num table
#echo "`date` : Start Collect TREB Picture Count " >>$mlslog
#$scriptdir/count_pic_num.sh
#echo "`date` : End Treb Pic Count Update " >>$mlslog


#generate TN and MID size pic and sync to CDN
#echo "`date` : Start Thumbnail  and CDN Sync " >>$mlslog
#$scriptdir/generate_tn.sh
#echo "`date` : End  Thumbnail and  CDN Sync " >>$mlslog


#export CSV and load into MapleCity
$scriptdir/export_resi_vow.sh
echo "`date` : Maplecity Resi DB load is completed" >>$mlslog
$scriptdir/export_condo_vow.sh 
echo "`date` : Maplecity Condo DB load is completed" >>$mlslog




#sync vow picture
#$scriptdir/picsync_vowlocal.sh
#

#Generate local house table and sync to google VM
$scriptdir/clone_h_housetmp.sh 1

#send notification
echo "`date` : Send Notification Start" >>$mlslog
cd $scriptdir/sendgrid
#source ./sendgrid.env
php -f ./email.php
echo "`date` : Send Notification End" >>$mlslog
