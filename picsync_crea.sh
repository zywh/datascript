#!/bin/sh

mlslog="/home/ubuntu/log/mlslog.txt"
rm -rf /mls/crea/Ontario/*
rm -rf /mls/crea/Alberta/*
rm -rf /mls/crea/NovaScotia/*
rm -rf /mls/crea/NewfoundlandLabrador/*
rm -rf /mls/crea/NewBrunswick/*
rm -rf /mls/crea/BritishColumbia/*
rm -rf /mls/crea/PrinceEdwardIsland/*

remote="/var/www/html/mlspic/crea/"
echo "`date`: Start Download CREA Pic " >>$mlslog
cd /home/ubuntu/script/crea/phRETS/PHRetsForCREA-master
php -f downloadpic.php
echo "`date`: End Download CREA Pic " >>$mlslog

#check resi picture and get list of missing picture

cd  /mls/crea
tar cvf /mls/tmp/creapic.tar ./*
echo "`date`: Start SCP CREA Pic " >>$mlslog
scp /mls/tmp/creapic.tar dzheng@alinew:/var/www/html/mlspic/tmp
ssh dzheng@alinew "cd /var/www/html/mlspic/crea;sudo tar xvf /var/www/html/mlspic/tmp/creapic.tar"
echo "`date`: End SCP and Untar  CREA Pic " >>$mlslog
echo "`date`: Copy CREA pictures to /disks/crea  " >>$mlslog
cd /mls/crea
sudo  cp -r ./* /disk2/crea/

echo "`date`: Start CREA count for pic_num " >>$mlslog
/home/ubuntu/script/count_crea_pic_num.sh
echo "`date`: End CREA count for pic_num " >>$mlslog
