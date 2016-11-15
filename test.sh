#!/bin/bash

########################
#Global  Parameter
########################
HOST='172.30.0.108'
PASSWD='19701029'
USER='mls'
homedir="/mls/172.30.0.108"
residata="$homedir/resi/data/data.txt"
resipic="$homedir/resi/picture"
condodata="$homedir/condo/data/data.txt"
condopic="$homedir/condo/picture"

vowresidata="$homedir/vowresi/data/data.txt"
vowresipic="$homedir/vowresi/picture"
vowcondodata="$homedir/vowcondo/data/data.txt"
vowcondopic="$homedir/vowcondo/picture"

mlslog="/home/ubuntu/log/mlslog.txt"

#load_vow.sh

#################################


########################################################
#Reconsile Active Listing
#Get List of Active from Table


	sort /tmp/resi_mls |uniq -c|grep "1 "|awk '{print $2}' | while read line
	do
	sql="delete from h_house where ml_num='$line';"
	echo "$sql"
	#mysql -u root -p19701029 -N -B mls -e "$sql"
	done


