#!/bin/bash

geoapi="https://maps.googleapis.com/maps/api/geocode/json?address="
key="AIzaSyAWB8vpdbzBZGt43jHqdxm1n6z6-516dQo"

[ -f latlng.txt ] && rm latlng.txt
[ -f results.json ] && rm results.json

while read line; do
    # Get address from column 3 and 4 of a CSV file provided as argument and prepare the string address. YMMV.
    	address=`cut -d"|" -f2-4 <<<$line | tr '|' '+' | tr ' ' '+'`
	mls=`cut -d"|" -f1 <<<$line`
    #curl -G -s --data sensor=true --data-urlencode address=$address "$MAPSAPIURL" -o results.json
    curl "$geoapi$address&key=$key" -o results.json
    # Parse json with jshon (http://kmkeen.com/jshon/)
    location=`jshon -e results -a -e geometry -e location -e "lat" -u -p -e "lng" -u < results.json | head -2 | paste -d, - - `
	echo $mls,$location
    #sleep 1
done < $1

