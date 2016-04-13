#!/bin/sh

mlslog="/home/ubuntu/log/mlslog.txt"
rm -rf /mls/tmp/picture/*
#remote="/var/www/html/mlspic/resi/picture"
remote="/var/www/html/mlspic/crea/Ontario"
echo "`date`:Get list of Remote DIR" >>$mlslog

ssh dzheng@alinew " ls $remote" >/tmp/remotedir

echo "`date`: Remote Picture Dir -`wc -l /tmp/remotedir`" >>$mlslog

#check resi picture and get list of missing picture

cd  /mls/172.30.0.108/resi/picture/

ls | while read line
do

dir=$line
dir1=`echo $dir | sed 's/Photo//'`
grep $dir1 /tmp/remotedir
if [ $? = 1 ]
then
	echo "Redi $dir doesn't exist. Add $dir into copy tar file"
	cp -r $dir /mls/tmp/picture
fi
done

#Check missing condo pictures
cd  /mls/172.30.0.108/condo/picture/

ls | while read line
do

dir=$line
dir1=`echo $dir | sed 's/Photo//'`
grep $dir1 /tmp/remotedir
if [ $? = 1 ]
then
	echo "Condo $dir doesn't exist. Add $dir into copy tar file"
        cp -r $dir /mls/tmp/picture
fi
done


#tar PIC file
cd /mls/tmp/picture
echo "`date`: Incremental Picture Dir for SYNC-`ls |wc -l `" >>$mlslog
tar cvf /tmp/pic.tar ./*


echo "`date`: Start SCP Pic TAR to Remote Server" >>$mlslog
scp /tmp/pic.tar dzheng@alinew:/tmp/pic.tar 
echo "`date`: Complete SCP Pic TAR to Remote Server" >>$mlslog

#ssh dzheng@alinew "cd /var/www/html/mlspic/resi/picture;sudo tar xvf /tmp/pic.tar"
#Change to new folder to prepare CREA
ssh dzheng@alinew "cd /var/www/html/mlspic/crea/Ontario;sudo tar xvf /tmp/pic.tar"

echo "`date` : Picture SYNC is completed" >>$mlslog

#export CSV and load into MapleCity
/home/ubuntu/script/export_resi.sh
echo "`date` : Maplecity Resi DB load is completed" >>$mlslog
/home/ubuntu/script/export_condo.sh
echo "`date` : Maplecity Condo DB load is completed" >>$mlslog

#
