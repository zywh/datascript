#!/bin/bash

########################
#Global  Parameter
########################
creadir="/disk2/crea"
#################################



picdir="/disk2/crea"
middir="/disk2/crea/creamid"
tndir="/disk2/crea/creatn"
sqlcmd="mysql -u root -p19701029 mls"

function clean_pic  {
province=$1
id=$2
safe=$3
cd $picdir/$province
#echo "$picdir/$province"
$sqlcmd  -N -B -e "select ml_num from crea where county='$id';" >/tmp/mlsactive
count=`wc -l </tmp/mlsactive`
if [ $count -lt $safe ]
then
echo "Active list $count is less than $safe"
exit 0
fi
ls -f | sed 's/Photo//'  >/tmp/current
cat /tmp/mlsactive /tmp/current >/tmp/list_getdeletepic
sort /tmp/list_getdeletepic |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "$picdir/$province"
cd $picdir/$province
echo "rm -r ./Photo$line"
#exit 0
rm -r ./Photo$line
cd $middir/$province
rm -r ./Photo$line
cd $tndir/$province
rm -r ./Photo$line
done


}


clean_pic  BritishColumbia "British Columbia" 5000
clean_pic  Alberta "Alberta" 5000
clean_pic  NewfoundlandLabrador 'Newfoundland & Labrador' 4000
clean_pic  PrinceEdwardIsland 'Prince Edward Island' 1000
clean_pic  NewBrunswick 'New Brunswick' 1000
clean_pic  NovaScotia 'Nova Scotia' 1000
clean_pic  Ontario "Ontario" 29000


