#!/bin/bash
srcdir="/disk2/crea"
smalldir="/disk2/creatn"
middir="/disk2/creamid"
logfile="/home/ubuntu/log/generatepic.log"

echo "`date` :Start Generate CREA thumbnail" >> $logfile


function convert_thumbnail  {
prov=$2
cd $1
echo "scan $1"
du -a|egrep "\-[1-3].jp"|awk '{print $2}' |  while read line
#find ./ |egrep "\-[1-3].jp" | while read line

do
#echo "convert $line /tmp/thumbnail.tmp"
#dirtmp=`echo $line |sed 's:\./::'`
dir=`echo $line |sed 's/\.\/\(.*\)\/.*/\1/'` 
smalldirp="$smalldir/$prov/$dir"
middirp="$middir/$prov/$dir"
file=`echo $line |sed 's/.*\///'`
#echo $fullfile, $middirp
#dirtmp=`echo $line |sed 's:.*\./::'`
#smalldirpic="$smalldir/$dirtmp"

if   [ ! -d $smalldirp ]
then
	#mkdir $smalldirpic
        echo "Create TN PIC  $smalldirp"
	mkdir  $smalldirp 
	#convert -thumbnail 100 $line $smalldirpic/
	#echo " install -D /tmp/thumbnail.tmp $smalldirpic"
	#install -D /tmp/thumbnail.tmp $smalldirpic
	fullfile="$smalldirp/$file"
	echo "convert -thumbnail 100 $line $fullfile"
	convert -thumbnail 100 $line $fullfile
fi

#middirpic="$middir/$dirtmp"
echo $line |grep "1.jp"
if [ $? -eq "0" ] &&   [ !  -d $middirp ]
then
        echo "Create MID PIC $middirp"
        mkdir $middirp
	fullfile="$middirp/$file"
	echo "convert -thumbnail 100 $line $fullfile"
        convert -thumbnail 320 $line $fullfile

fi

#Generate medium size pic

done

}


convert_thumbnail  $srcdir/Ontario Ontario
convert_thumbnail  $srcdir/PrinceEdwardIsland PrinceEdwardIsland
convert_thumbnail  $srcdir/NovaScotia NovaScotia
convert_thumbnail  $srcdir/NewBrunswick NewBrunswick
convert_thumbnail  $srcdir/BritishColumbia BritishColumbia
convert_thumbnail  $srcdir/Alberta Alberta
convert_thumbnail  $srcdir/NewfoundlandLabrador NewfoundlandLabrador
echo "`date` :End Generate thumbnail" >> $logfile


