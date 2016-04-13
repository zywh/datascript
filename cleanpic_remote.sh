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
exit 0
cp /tmp/resi_mls_a /tmp/resi_remote_a
ls $resipic | sed 's/Photo//'  >>/tmp/resi_mls_a
sort /tmp/resi_mls_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "rm -r $resipic/Photo$line"
rm -r $resipic/Photo$line
done


#Reconcile remote Pic DIR

ssh root@ali ls /mls/resi/picture  | sed 's/Photo//'  >>/tmp/resi_remote_a
sort /tmp/resi_remote_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "ssh root@ali rm -r /mls/resi/picture/Photo$line"
ssh root@ali rm -r /mls/resi/picture/Photo$line </dev/null
done

exit 0
echo "Check Condo MLS"
mysql -u root -p19701029 -N -B mls -e 'select ml_num from condo where status="A"' >/tmp/condo_mls_a

ls $condopic| sed 's/Photo//'  >>/tmp/condo_mls_a
sort /tmp/condo_mls_a |uniq -c|grep "1 "|awk '{print $2}' | while read line
do
echo "rm -r $condopic/Photo$line"
rm -r $condopic/Photo$line
done


