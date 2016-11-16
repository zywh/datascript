#!/bin/bash
srcdir="/disk2/crea"
creafile="/tmp/crea.update"
smalldir="/disk2/creatn"
middir="/disk2/creamid"
logfile="/home/ubuntu/log/generatepic.log"

echo "`date` :Start Generate CREA thumbnail" >> $logfile


function convert_thumbnail  {
prov=$2
mlsp="Photo$1"
srcdir="/disk2/crea/$prov/$mlsp"
echo $srcdir
ls $srcdir| egrep "\-[1-3].jp"| while read line
do
smalldirp="$smalldir/$prov/$mlsp"
middirp="$middir/$prov/$mlsp"
file=$line
echo "Target file $smalldirp/$file"
echo "Target file $middirp/$file"
#echo $fullfile, $middirp
#dirtmp=`echo $line |sed 's:.*\./::'`
#smalldirpic="$smalldir/$dirtmp"

if   [ ! -d $smalldirp ]
then
        echo "Create TN PIC  $smalldirp"
	mkdir  $smalldirp 
	fullfile="$smalldirp/$file"
	echo "convert -thumbnail 100 $line $fullfile"
	#convert -thumbnail 100 $line $fullfile
fi

echo $line |grep "1.jp"
if [ $? -eq "0" ] &&   [ !  -d $middirp ]
then
        echo "Create MID PIC $middirp"
        mkdir $middirp
	fullfile="$middirp/$file"
	echo "convert -thumbnail 100 $line $fullfile"
        #convert -thumbnail 320 $line $fullfile

fi

#Generate medium size pic

done

}

awk -F"|" '{print $3"|"$67}' $creafile|sed 's/[ &]//g'|sed 's/|/ /' | while read line
do
set $line
convert_thumbnail $1 $2

done

echo "`date` :End Generate thumbnail" >> $logfile


