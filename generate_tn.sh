#!/bin/bash
srcdir1="/mls/172.30.0.108/vowresi/picture"
srcdir2="/mls/172.30.0.108/vowcondo/picture"
treb_srcdir='/mls/treb'
smalldir="/mls/trebtn"
middir="/mls/trebmid"
logfile="/home/ubuntu/log/generatepic.log"

echo "`date` :Start Generate thumbnail" >> $logfile


function convert_thumbnail  {
srcdir=$1
cd $srcdir
echo "scan $srcdir"
find ./ |egrep "\-[1-3].jp" | while read line

do
#echo "convert $line /tmp/thumbnail.tmp"
dirtmp=`echo $line |sed 's:\./::'`
smalldirpic="$smalldir/$dirtmp"

if   [ ! -f $smalldirpic ]
then
	convert -thumbnail 100 $line /tmp/thumbnail.tmp
	echo " install -D /tmp/thumbnail.tmp $smalldirpic"
	install -D /tmp/thumbnail.tmp $smalldirpic
fi

middirpic="$middir/$dirtmp"
echo $line |grep "1.jp"
if [ $? -eq "0" ] &&   [ !  -f $middirpic ]
then
        convert -thumbnail 320 $line /tmp/thumbnail.tmp
        echo " install -D /tmp/thumbnail.tmp $middirpic"
        install -D /tmp/thumbnail.tmp $middirpic

fi

#Generate medium size pic

done

}


convert_thumbnail  $treb_srcdir
echo "`date` :End Generate thumbnail" >> $logfile

cd $smalldir
rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -va --delete ./ user_fzuh930p@push-24.cdn77.com:/www/trebtn/
echo "`date` :End RSYNC CDN thumbnail" >> $logfile

cd $middir
rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -va --delete ./ user_fzuh930p@push-24.cdn77.com:/www/trebmid/

echo "`date` :End RSYNC CDN Mid Size Picture" >> $logfile


#Delete Resi on Windows
HOST="push-24.cdn77.com"
USER="user_fzuh930p"

#rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -arv --delete /mls/empty/ user_fzuh930p@push-24.cdn77.com:/www/tn/
#Delete Condo on Windows

