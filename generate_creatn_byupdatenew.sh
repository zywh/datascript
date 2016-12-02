#!/bin/bash
srcdir="/disk2/crea"
creafile="/tmp/crea.update"
smalldir="/disk2/creatn"
middir="/disk2/creamid"
logfile="/home/ubuntu/log/generatepic.log"

#get list of active crea
echo "`date` :Start Generate CREA thumbnail" >> $logfile
sql="
select concat(replace(replace(county,' ',''),'&',''),'/Photo',ml_num) 
from crea
INTO OUTFILE '/tmp/active_crea4tn.csv'

"
echo "export crea list into tmp file"
sudo rm /tmp/active_crea4tn.csv
/usr/bin/mysql -u root -p19701029 mls -e "$sql"

#get list of current mid files



#output file /tmp/creamid_list

#check if active crea in mid list of not



function convert_thumbnail  {
prov=$2
mlsp="Photo$1"
srcdir="/disk2/crea/$prov/$mlsp"
smalldirp="$smalldir/$prov/$mlsp"
middirp="$middir/$prov/$mlsp"
ls $srcdir| egrep "\-[1-3].jp"| while read line
do
#echo $line
#echo "Target file $smalldirp/$line"
#echo "Target file $middirp/$line"
#echo $fullfile, $middirp
#dirtmp=`echo $line |sed 's:.*\./::'`
#smalldirpic="$smalldir/$dirtmp"
srcfile="$srcdir/$line"
if   [ ! -d $smalldirp ]
then
        echo "Create TN PIC  $smalldirp"
	mkdir  $smalldirp 
	fullfile="$smalldirp/$line"
	echo "convert -thumbnail 100 $srcfile $fullfile"
	convert -thumbnail 100 $srcfile $fullfile
fi

echo $line |grep "1.jp"
if [ $? -eq "0" ] &&   [ !  -d $middirp ]
then
        echo "Create MID PIC $middirp"
        mkdir $middirp
	fullfile="$middirp/$line"
	echo "convert -thumbnail 100 $srcfile $fullfile"
        convert -thumbnail 320 $srcfile $fullfile

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


