#!/bin/sh

exit 0
mlslog="/home/ubuntu/log/mlslog.txt"
rm -rf /mls/tmp/picture/*
#remote="/var/www/html/mlspic/resi/picture"
remote="/var/www/html/mlspic/crea/Ontario"
echo "`date`:Get list of Remote DIR" >>$mlslog

ssh dzheng@alinew " ls $remote" >/tmp/remotedir

echo "`date`: Remote Picture Dir -`wc -l /tmp/remotedir`" >>$mlslog

#check resi picture and get list of missing picture

cd  /mls/treb

ls | while read line
do

dir=$line
dir1=`echo $dir | sed 's/Photo//'`
if [ -n "$dir1" ]
then
	grep $dir1 /tmp/remotedir
	if [ $? = 1 ]
		then
		echo "Resi $dir doesn't exist. Add $dir into copy tar file"
		cp -r $dir /mls/tmp/picture
	fi
fi
done

#Check missing condo pictures


#tar PIC file
cd /mls/tmp/picture
echo "`date`: Incremental Picture Dir for SYNC-`ls |wc -l `" >>$mlslog
tar cvf /tmp/pic.tar ./*

echo "`date`: Start SCP Pic TAR to Remote Server" >>$mlslog
scp /tmp/pic.tar dzheng@alinew:/var/www/html/mlspic/tmp/pic.tar 
echo "`date`: Complete SCP Pic TAR to Remote Server" >>$mlslog

ssh dzheng@alinew "cd /var/www/html/mlspic/resi/picture;sudo tar xvf /tmp/pic.tar"
#Change to new folder to prepare CREA
#ssh dzheng@alinew "cd /var/www/html/mlspic/crea/Ontario;sudo tar xvf /var/www/html/mlspic/tmp/pic.tar"

echo "`date` : Picture SYNC is completed" >>$mlslog

#export CSV and load into MapleCity
#/home/ubuntu/script/export_resi_vow.sh
#echo "`date` : Maplecity Resi DB load is completed" >>$mlslog
#/home/ubuntu/script/export_condo_vow.sh
#echo "`date` : Maplecity Condo DB load is completed" >>$mlslog

#
#echo "`date` : Start picture cleanup" >>$mlslog

#ssh dzheng@alinew "/home/dzheng/script/cleanpic.sh"
#echo "`date` : End picture cleanup" >>$mlslog


#rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -va --delete ./ user_fzuh930p@push-24.cdn77.com:/www/treb
