#!/bin/sh

mlslog="/home/ubuntu/log/mlslog.txt"
scriptdir="/home/ubuntu/script"
#download crea data and load into crea table
$scriptdir/load_crea.sh

#Download vow data/picture and idx ml_num
$scriptdir/load_vow.sh

echo "`date` : Start TREB picture cleanup" >>$mlslog
sudo $scriptdir/cleanpic.sh
echo "`date` : End TREB picture cleanup" >>$mlslog

#Update treb pic_num table
echo "`date` : Start Collect TREB Picture Count " >>$mlslog
$scriptdir/count_pic_num.sh
echo "`date` : End Treb Pic Count Update " >>$mlslog

#Local VOW data into local resi and condo table
$scriptdir/loadmls_vowlocal.sh

#sync vow pic to CDN
echo "`date` : Start VOW Pic CDN Sync " >>$mlslog
cd /mls/treb
rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -va --delete ./ user_fzuh930p@push-24.cdn77.com:/www/treb
echo "`date` : End VOW Pic CDN Sync" >>$mlslog

#generate TN and MID size pic and sync to CDN
echo "`date` : Start Thumbnail  and CDN Sync " >>$mlslog
$scriptdir/generate_tn.sh
echo "`date` : End  Thumbnail and  CDN Sync " >>$mlslog


echo "`date` : Start CREA Thumbnail" >>$mlslog
$scriptdir/generate_crea_tn.sh
echo "`date` : End  CREA Thumbnail " >>$mlslog



#export CSV and load into MapleCity
$scriptdir/export_resi_vow.sh
echo "`date` : Maplecity Resi DB load is completed" >>$mlslog
$scriptdir/export_condo_vow.sh
echo "`date` : Maplecity Condo DB load is completed" >>$mlslog




#sync vow picture
#$scriptdir/picsync_vowlocal.sh
#



echo "`date` : Start picture cleanup" >>$mlslog
#ssh dzheng@alinew "/home/dzheng/script/cleanpic.sh"
echo "`date` : End picture cleanup" >>$mlslog


#Generate local house table and sync to google VM
$scriptdir/clone_h_housetmp.sh
