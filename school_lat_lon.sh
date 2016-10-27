#!/bin/bash


pass="19701029"
table="h_school"
sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "


# generate LON and LAT

#Export Address List
exportloc="
select
schoolnumber ,
concat(address,' ',city,' ',province,' ',zip)
FROM h_school
INTO OUTFILE '/tmp/map.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

echo "export address into tmp file"
#`$sqlcmd  -e "$exportloc"`

count=`wc -l /tmp/school.csv`
echo "Export School Address Google Map API - $count"


#Prepare Google GeoLocation API

cd /tmp
geoapi="https://maps.googleapis.com/maps/api/geocode/json?address="
key="AIzaSyAWB8vpdbzBZGt43jHqdxm1n6z6-516dQo"

[ -f schoollatlng.txt ] && sudo rm schoollatlng.txt
[ -f sresults.json ] && rm sresults.json

while read line; do
    address=`cut -d"|" -f2 <<<$line | tr '|' '+' | tr ' ' '+'`
    id=`cut -d"|" -f1 <<<$line`
    curl "$geoapi$address&key=$key" -o sresults.json
	echo "$geoapi$address&key=$key"
    # Parse json with jshon (http://kmkeen.com/jshon/)
    location=`jshon -e results -a -e geometry -e location -e "lat" -u -p -e "lng" -u < sresults.json | head -2 | paste -d, - - `
	#Generate location CSV
	lat=`echo $location |cut -d"," -f1`
	lng=`echo $location |cut -d"," -f2`
	echo $lat,$lng
        echo "update $table set lat=$lat,lng=$lng where schoolnumber='$id'; ">>/tmp/schoollatlng.txt
done < /tmp/school.csv



