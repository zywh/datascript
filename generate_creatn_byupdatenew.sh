#!/bin/bash
srcdir="/disk2/crea"
creafile="/tmp/crea.update"
smalldir="/disk2/creatn"
middir="/disk2/creamid"
logfile="/home/ubuntu/log/generatepic.log"
crea_active="/tmp/active_crea4tn.csv";
current_mid="/tmp/current_mid.txt"

#get list of active crea
echo "`date` :Start Generate CREA thumbnail" >> $logfile
sql="
select concat(replace(replace(county,' ',''),'&',''),'/Photo',ml_num) 
from crea
INTO OUTFILE '$crea_active'

"
echo "export crea list into tmp file"
sudo rm $crea_active
/usr/bin/mysql -u root -p19701029 mls -e "$sql"

#get list of current mid files


function scan_pic  {
province=$1
cd $middir/$province
echo "$middir/$province"

du -a |grep "1\.jpg" | sed 's/.*Photo\(.*\)-1.jpg/\1/' |while read line
do
echo "$province/Photo$line"
done >>$current_mid
}


sudo rm $current_mid
scan_pic  Ontario "Ontario"
scan_pic  BritishColumbia "British Columbia"
scan_pic  Alberta "Alberta"
scan_pic  NewfoundlandLabrador 'Newfoundland & Labrador'
scan_pic  PrinceEdwardIsland 'Prince Edward Island'
scan_pic  NewBrunswick 'New Brunswick'
scan_pic  NovaScotia 'Nova Scotia'


#check if active crea in mid list of not



function convert_thumbnail  {
mls=`echo $1 |sed 's/.*Photo//'`
srcfile1="$srcdir/$1/Photo$mls-1.jpg"
srcfile2="$srcdir/$1/Photo$mls-2.jpg"
srcfile3="$srcdir/$1/Photo$mls-3.jpg"
midfile="$middir/$1/Photo$mls-1.jpg"
tn1="$smalldir/$1/Photo$mls-1.jpg"
tn2="$smalldir/$1/Photo$mls-2.jpg"
tn3="$smalldir/$1/Photo$mls-3.jpg"

echo "convert -thumbnail 320 $srcfile1 $midfile"
#convert -thumbnail 320 $srcfile1 $midfile

echo "convert -thumbnail 100 $srcfile1 $tn1"
#convert -thumbnail 100 $srcfile1 $tn1
echo "convert -thumbnail 100 $srcfile2 $tn2"
#convert -thumbnail 100 $srcfile2 $tn2
echo "convert -thumbnail 100 $srcfile3 $tn3"
#convert -thumbnail 100 $srcfile3 $tn3


}

cat $crea_active | while read line
do

grep $line $current_mid
if [ $? -ne "0" ] 
then
	srcfolder="$srcdir/$line"
	if [ -d $srcfolder ]
	then
		convert_thumbnail $line 
	fi

fi

done

#echo "`date` :End Generate thumbnail" >> $logfile


