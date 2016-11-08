#!/bin/bash
srcdir="/disk2/crea/"
smalldir="/disk2/creatn"
middir="/disk2/creamid"
logfile="/home/ubuntu/log/generatepic.log"

echo "`date` :Start Generate CREA thumbnail" >> $logfile


function convert_thumbnail  {
srcdir=$1
cd $srcdir
echo "scan $srcdir"
du -a|egrep "\-[1-3].jp"| while read line
#find ./ |egrep "\-[1-3].jp" | while read line

do
#echo "convert $line /tmp/thumbnail.tmp"
#dirtmp=`echo $line |sed 's:\./::'`
dirtmp=`echo $line |sed 's:.*\./::'`
echo "dirtmp $dirtmp"
smalldirpic="$smalldir/$dirtmp"
echo "smalldirpci $smalldirpic"

if   [ ! -f $smalldirpic ]
then
	#mkdir $smalldirpic
	dir=`echo $smalldirpic |sed 's/\(.*\)\/.*/\1/'` 
        echo "Create TN PIC $dir"
	mkdir $dir
	convert -thumbnail 100 $line $smalldirpic
	#convert -thumbnail 100 $line $smalldirpic/
	#echo " install -D /tmp/thumbnail.tmp $smalldirpic"
	#install -D /tmp/thumbnail.tmp $smalldirpic
fi

middirpic="$middir/$dirtmp"
echo $line |grep "1.jp"
if [ $? -eq "0" ] &&   [ !  -f $middirpic ]
then
       	dir=`echo $middirpic |sed 's/\(.*\)\/.*/\1/'`
        echo "Create MID PIC $dir"
        mkdir $dir
        convert -thumbnail 320 $line $middirpic

        #convert -thumbnail 320 $line /tmp/thumbnail.tmp
        #echo " install -D /tmp/thumbnail.tmp $middirpic"
        #install -D /tmp/thumbnail.tmp $middirpic

fi

#Generate medium size pic

done

}


convert_thumbnail  $srcdir
echo "`date` :End Generate thumbnail" >> $logfile

exit 0

cd $smalldir
rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -va --delete ./ user_fzuh930p@push-24.cdn77.com:/www/trebtn/
echo "`date` :End RSYNC CDN thumbnail" >> $logfile

cd $middir
rsync -e "ssh -i /home/ubuntu/.ssh/id_rsa" -va --delete ./ user_fzuh930p@push-24.cdn77.com:/www/trebmid/

echo "`date` :End RSYNC CDN Mid Size Picture" >> $logfile




