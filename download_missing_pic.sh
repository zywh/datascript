#!/bin/bash

########################
#Global  Parameter
homedir="/mls/172.30.0.108"
residata="$homedir/resi/data/data.txt"
condodata="$homedir/condo/data/data.txt"
trebpicdir="/mls/treb"
#################################

cd $trebpicdir
find . -name "*-1.jpeg" |sed 's/.*Photo\(.*\)-1.jpeg/\1/' >/tmp/treb_pic_avail
cat $homedir/vowcondo/data/avail.txt $homedir/vowresi/data/avail.txt | while read line
do
grep $line /tmp/treb_pic_avail
if [ $? -ne '0' ]
	then
	echo "download missing picture $line"
fi

done



