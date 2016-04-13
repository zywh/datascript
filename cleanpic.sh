#!/bin/bash

########################
#Global  Parameter
########################
HOST='172.30.0.108'
PASSWD='19701029'
USER='mls'
homedir="/mls/172.30.0.108"
#homedir="/mls/mirror"
residata="$homedir/resi/data/data.txt"
resipic="$homedir/resi/picture"
condodata="$homedir/condo/data/data.txt"
condopic="$homedir/condo/picture"
#################################



#Get Current Active List from table
mysql -u root -p19701029 -N -B mls -e 'select ml_num from resi where status="A"' >/tmp/resi_mls_a
cp /tmp/resi_mls_a /tmp/activemls
ls $resipic | sed 's/Photo//'  >>/tmp/resi_mls_a
sort /tmp/resi_mls_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "rm -r $resipic/Photo$line"
rm -r $resipic/Photo$line
done



echo "Check Condo MLS"
mysql -u root -p19701029 -N -B mls -e 'select ml_num from condo where status="A"' >/tmp/condo_mls_a
cat /tmp/condo_mls_a >>/tmp/activemls

ls $condopic| sed 's/Photo//'  >>/tmp/condo_mls_a
sort /tmp/condo_mls_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "rm -r $condopic/Photo$line"
rm -r $condopic/Photo$line
done


#Generate cleanup list for remote dir

echo "Generate list for remote cleannup"
remote="/var/www/html/mlspic/resi/picture"

ssh dzheng@alinew " ls $remote" >/tmp/remotedir
remotedir="/tmp/remotedir"
rm /tmp/dirtbd
cat $remotedir | while read line
do 
id=`echo $line |sed 's/Photo//'`
grep $id /tmp/activemls
if [ $? = 1 ]
then
        echo "MLS $line doesn't exist"
	echo $line >> /tmp/dirtbd
	
fi

done

scp /tmp/dirtbd dzheng@alinew:/tmp/dirtbd
