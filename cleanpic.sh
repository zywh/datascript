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
#resipic="$homedir/resi/picture"
resipic="/mls/treb"
trebmid="/mls/trebmid"
condodata="$homedir/condo/data/data.txt"
#condopic="$homedir/condo/picture"
condopic="/mls/treb"
#################################



#Get Current Active List from table
#mysql -u root -p19701029 -N -B mls -e 'select ml_num from vowresi where status="A"' >/tmp/mls_a
#mysql -u root -p19701029 -N -B mls -e 'select ml_num from vowcondo where status="A"' >>/tmp/mls_a
cat $homedir/vowcondo/data/avail.txt $homedir/vowresi/data/avail.txt >/tmp/mls_a
count=`wc -l< /tmp/mls_a`
if [ $count -lt 15000 ]
then
echo "record $count is low for cleanup"
exit 4
fi
cp /tmp/mls_a /tmp/activemls
#clean up TREB PIC
ls $resipic | sed 's/Photo//'  >>/tmp/mls_a
sort /tmp/mls_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "rm -r $resipic/Photo$line"
rm -r $resipic/Photo$line
done
#Backup TREBMID
echo "backup trebmid"
cat $homedir/vowcondo/data/avail.txt $homedir/vowresi/data/avail.txt >/tmp/mls_a
ls $trebmid | sed 's/Photo//'  >>/tmp/mls_a
sort /tmp/mls_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "mv $trebmid/Photo$line /disk2/pichist/trebmid"
mv $trebmid/Photo$line /disk2/pichist/trebmid
done

