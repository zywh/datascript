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
FROM resi
WHERE county ='Ontario' 
AND ml_num REGEXP '[a-z][0-9].*' 
AND  ml_num not in (select ml_num from location)
INTO OUTFILE '/tmp/map.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

echo "export address into tmp file"
sudo rm /tmp/map.csv
/usr/bin/mysql -u root -p$pass mls -e "$exportloc"
echo "Exported Address $count"


#Prepare Google GeoLocation API

cd /tmp
geoapi="https://maps.googleapis.com/maps/api/geocode/json?address="
key="AIzaSyAWB8vpdbzBZGt43jHqdxm1n6z6-516dQo"

[ -f latlng.txt ] && sudo rm latlng.txt
[ -f results.json ] && rm results.json

while read line; do
        address=`cut -d"|" -f2-4 <<<$line | tr '|' '+' | tr ' ' '+'`
        mls=`cut -d"|" -f1 <<<$line`
    curl "$geoapi$address&key=$key" -o results.json
    # Parse json with jshon (http://kmkeen.com/jshon/)
    location=`jshon -e results -a -e geometry -e location -e "lat" -u -p -e "lng" -u < results.json | head -2 | paste -d, - - `
	#Generate location CSV 
        echo $mls,$location >>/tmp/latlng.txt
    #sleep 1
done < /tmp/map.csv

#Clean location table

#echo "Delete location table......"


#/usr/bin/mysql -u root -p$pass mls -e "delete from location;"

#Load location file into table

echo "Load location file into table"

loadsql="LOAD DATA INFILE '/tmp/latlng.txt'  ignore INTO TABLE location   FIELDS TERMINATED BY ',' ;"
sudo chown mysql:mysql /tmp/latlng.txt
/usr/bin/mysql -u root -p$pass mls -e "$loadsql"



#Export CSV for LOADING
echo "Export Data for maplecity tabe"
exportresi="
select  
concat('mlspic/resi/picture/Photo',resi.ml_num,'/Photo',resi.ml_num,'-1.jpeg') ,
lat ,
lon ,
addr	,
a_c	,
yr_built	,
sqft	,
area	,
area_code	,
bsmt1_out	,
bsmt2_out	,
br	,
br_plus	,
central_vac	,
community	,
community_code	,
cross_st	,
elevator	,
constr1_out	,
constr2_out	,
extras	,
fpl_num	,
comp_pts	,
furnished	,
gar_spaces	,
fuel	,
heating	,
num_kit	,
kit_plus	,
level1	,
level10	,
level11	,
level12	,
level2	,
level3	,
level4	,
level5	,
level6	,
level7	,
level8	,
level9	,
lp_dol	,
depth	,
front_ft	,
lotsz_code	,
resi.ml_num	,
municipality	,
municipality_code	,
timestamp_sql ,
pool	,
replace(zip,' ','')	,
prop_feat1_out	,
prop_feat2_out	,
prop_feat3_out	,
prop_feat4_out	,
prop_feat5_out	,
prop_feat6_out	,
county	,
ad_text	,
rm1_out	,
rm1_dc1_out	,
rm1_dc2_out	,
rm1_dc3_out	,
rm1_len	,
rm1_wth	,
rm10_out	,
rm10_dc1_out	,
rm10_dc2_out	,
rm10_dc3_out	,
rm10_len	,
rm10_wth	,
rm11_out	,
rm11_dc1_out	,
rm11_dc2_out	,
rm11_dc3_out	,
rm11_len	,
rm11_wth	,
rm12_out	,
rm12_dc1_out	,
rm12_dc2_out	,
rm12_dc3_out	,
rm12_len	,
rm12_wth	,
rm2_out	,
rm2_dc1_out	,
rm2_dc2_out	,
rm2_dc3_out	,
rm2_len	,
rm2_wth	,
rm3_out	,
rm3_dc1_out	,
rm3_dc2_out	,
rm3_dc3_out	,
rm3_len	,
rm3_wth	,
rm4_out	,
rm4_dc1_out	,
rm4_dc2_out	,
rm4_dc3_out	,
rm4_len	,
rm4_wth	,
rm5_out	,
rm5_dc1_out	,
rm5_dc2_out	,
rm5_dc3_out	,
rm5_len	,
rm5_wth	,
rm6_out	,
rm6_dc1_out	,
rm6_dc2_out	,
rm6_dc3_out	,
rm6_len	,
rm6_wth	,
rm7_out	,
rm7_dc1_out	,
rm7_dc2_out	,
rm7_dc3_out	,
rm7_len	,
rm7_wth	,
rm8_out	,
rm8_dc1_out	,
rm8_dc2_out	,
rm8_dc3_out	,
rm8_len	,
rm8_wth	,
rm9_out	,
rm9_dc1_out	,
rm9_dc2_out	,
rm9_dc3_out	,
rm9_len	,
rm9_wth	,
rms	,
rooms_plus	,
s_r	,
style	,
yr	,
taxes	,
type_own1_out	,
tour_url	,
bath_tot	
FROM resi,location
WHERE resi.county ='Ontario' AND resi.ml_num REGEXP '[a-z][0-9].*' AND resi.ml_num = location.ml_num 
INTO OUTFILE '/tmp/resi.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"


#/usr/bin/mysql -u root -p19701029 mls -e "$exportcondo"
sudo rm /tmp/resi.csv*
echo "Export MLS Table for MaplyCity H_house"
/usr/bin/mysql -u root -p19701029 mls -e "$exportresi"



#Load Data into maplecity table

echo "Load SQL into Maplecity DB"
/home/ubuntu/script/loadmaple.sh


exit 0
#Get picture list from maplecity
ftp_site='hyu1076950001.my3w.com'
passwd='ftpmaplecity8888'
username='hyu1076950001'
remote="/htdocs/mlspic/resi"
lftp -u $username,$passwd $ftp_site -e " cd $remote;ls  picture ;exit" |awk '{print $9}' > /tmp/remotepicdir


