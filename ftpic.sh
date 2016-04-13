#!/bin/bash
ftp_site='hyu1076950001.my3w.com'
passwd='ftpmaplecity8888'
username='hyu1076950001'
remote="/htdocs/mlspic/resi"
resihome="/mls/172.30.0.108/resi"
tarfile="resipic.tar"
cd $resihome
#rm $tarfile
#tar cvf $tarfile ./picture/*
#scp $tarfile azureuser@mlsftp.cloudapp.net:$tarfile

#lftp -u $username,$passwd $ftp_site -e " cd $remote;mirror -R picture picture;exit"
ncftpput -u $username -p $passwd -R $ftp_site $remote /mls/tmp/picture


#ls | while read line
#do 
#folder=$line
#echo $resihome/$folder
#ftp -in <<EOF
#open $ftp_site
#user $username $passwd
#pass
#mkdir $remote/$folder
#lcd /mls/172.30.0.108/resi/picture/$folder
#cd $remote/$folder
#mput *
#close
#bye
#EOF

#done
