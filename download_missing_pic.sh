#!/bin/bash

########################
#Global  Parameter
homedir="/mls/172.30.0.108"
trebpicdir="/mls/treb"
source /home/ubuntu/script/script.env

#################################
rm /tmp/treb_download_list


cd $trebpicdir
find . -name "*-1.jpeg" |sed 's/.*Photo\(.*\)-1.jpeg/\1/' >/tmp/treb_pic_avail
cd /home/ubuntu/script/treb
cat $homedir/vowcondo/data/avail.txt $homedir/vowresi/data/avail.txt | while read line
do
grep $line /tmp/treb_pic_avail
if [ $? -ne '0' ]
	then
	echo "$line" >>/tmp/treb_download_list
fi

done

sudo php download_vow_missing_pic.php /tmp/treb_download_list $VOW_USER $VOW_PASS
 


