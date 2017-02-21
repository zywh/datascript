#!/bin/bash



source /home/ubuntu/script/script.env
pass=$SQL_LOCAL_PASS

# generate LON and LAT

#Export Address List
exportloc="
select
ml_num ,
addr    ,
municipality    ,
county
FROM h_housetmp
WHERE county ='Ontario' 
AND ml_num REGEXP '[a-z][0-9].*' 
AND latitude =0 
AND pix_updt > '2017-02-08'

INTO OUTFILE '/tmp/map.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

echo "export address into tmp file"
#sudo rm /tmp/map.csv
#/usr/bin/mysql -u root -p$pass mls -e "$exportloc"
count=`wc -l /tmp/map.csv`



#Prepare Google GeoLocation API

cd /tmp
geoapi="https://maps.googleapis.com/maps/api/geocode/json?address="
key=$GOOGLEMAP_APIKEY

[ -f latlng.txt ] && sudo rm latlng.txt
[ -f results.json ] && rm results.json

while read line; do
        address=`cut -d"|" -f2-4 <<<$line | tr '|' '+' | tr ' ' '+'`
        mls=`cut -d"|" -f1 <<<$line`
	echo "$geoapi$address&key=$key"
    curl "$geoapi$address&key=$key" -o results.json
	
    # Parse json with jshon (http://kmkeen.com/jshon/)
    location=`jshon -e results -a -e geometry -e location -e "lat" -u -p -e "lng" -u < results.json | head -2 | paste -d, - - `
	#Generate location CSV 
        echo $mls,$location >>/tmp/latlng.txt
    #sleep 1
done < /tmp/map.csv

#Clean location table
