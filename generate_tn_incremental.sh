#!/bin/bash
srcdir1="/mls/172.30.0.108/vowresi/picture"
srcdir2="/mls/172.30.0.108/vowcondo/picture"
treb_srcdir='/mls/treb'
smalldir="/mls/trebtn"
middir="/mls/trebmid"
logfile="/home/ubuntu/log/generatepic.log"
piccount="/tmp/treb_pic_count.tmp"
#piccount="/tmp/test.tmp"

echo "`date` :Start Generate Incremental TREB thumbnail" >> $logfile


function convert_thumbnail  {
id=$1
cd $treb_srcdir/Photo$id
echo "scan $treb_srcdir/Photo$id"
ls|egrep "\-[1-3].jp"| while read line

do
#echo "convert $line /tmp/thumbnail.tmp"
dirtmp="Photo$id"
smalldirpic="$smalldir/$dirtmp/$line"

if   [ ! -f $smalldirpic ]
then
	convert -thumbnail 100 $line /tmp/thumbnail.tmp
	echo " install -D /tmp/thumbnail.tmp $smalldirpic"
	install -D /tmp/thumbnail.tmp $smalldirpic
fi

middirpic="$middir/$dirtmp/$line"
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


cat $piccount |while read line
do
id=`echo $line|sed 's/,.*//'`
convert_thumbnail  $id
done

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

