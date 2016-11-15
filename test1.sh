#!/bin/bash


mlslog="/home/ubuntu/log/mlslog.txt"
pass="19701029"
scriptdir="/home/ubuntu/script"

# generate LON and LAT

#Export Address List
exportloc="
select
ml_num ,
addr    ,
municipality    ,
county
FROM vowresi
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
count=`wc -l /tmp/map.csv`
echo "`date`: Export Resi MLS for Google Map API - $count" >>$mlslog



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


cp /tmp/map.csv >>/tmp/newhouse.txt

echo "Load location file into table"

loadsql="LOAD DATA INFILE '/tmp/latlng.txt'  ignore INTO TABLE location   FIELDS TERMINATED BY ',' ;"
sudo chown mysql:mysql /tmp/latlng.txt
/usr/bin/mysql -u root -p$pass mls -e "$loadsql"


#Export CSV for LOADING
exportresi="
select  
pic_num.pic_num,
orig_dol,
oh_date1,
oh_from1,
oh_to1,
oh_date2,
oh_from2,
oh_to2,
oh_date3,
oh_from3,
oh_to3,
dom,
'VOW',
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
vowresi.ml_num	,
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
FROM vowresi
LEFT join location on vowresi.ml_num = location.ml_num
LEFT join pic_num  on vowresi.ml_num = pic_num.ml_num
WHERE vowresi.county ='Ontario' 
AND vowresi.ml_num REGEXP '[a-z][0-9].*' 
INTO OUTFILE '/tmp/resi.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"


#/usr/bin/mysql -u root -p19701029 mls -e "$exportcondo"
sudo rm /tmp/resi.csv*
echo "Export MLS Table for MaplyCity H_house"
/usr/bin/mysql -u root -p19701029 mls -e "$exportresi"
exit 0
echo "`date`: Resi Date for Import - `wc -l /tmp/resi.csv`" >>$mlslog


sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
sql="create table h_housetmp like h_house;"
`$sqlcmd -e "$sql"`

#Load New Data
sql="

LOAD DATA LOCAL infile '/tmp/resi.csv'
INTO TABLE h_housetmp
fields terminated BY \"|\"

(
pic_num, orig_dol, oh_date1, oh_from1, oh_to1, oh_date2, oh_from2, oh_to2, oh_date3, oh_from3, oh_to3, dom, src,latitude,longitude, addr    , a_c     , yr_built        , sqft    , area    , area_code       , bsmt1_out       , bsmt2_out       , br      , br_plus , central_vac     , community       , community_code  , cross_st        , elevator        , constr1_out     , constr2_out     , extras  , fpl_num , comp_pts        , furnished       , gar_spaces      , fuel    , heating , num_kit , kit_plus        , level1  , level10 , level11 , level12 , level2  , level3  , level4  , level5  , level6  , level7  , level8  , level9  , lp_dol  , depth   , front_ft        , lotsz_code      , ml_num  , municipality    , municipality_code       , pix_updt        , pool    , zip    , prop_feat1_out  , prop_feat2_out  , prop_feat3_out  , prop_feat4_out  , prop_feat5_out  , prop_feat6_out  , county  , ad_text , rm1_out , rm1_dc1_out     , rm1_dc2_out     , rm1_dc3_out     , rm1_len , rm1_wth , rm10_out        , rm10_dc1_out    , rm10_dc2_out    , rm10_dc3_out    , rm10_len        , rm10_wth        , rm11_out        , rm11_dc1_out    , rm11_dc2_out    , rm11_dc3_out    , rm11_len        , rm11_wth        , rm12_out        , rm12_dc1_out    , rm12_dc2_out    , rm12_dc3_out    , rm12_len        , rm12_wth        , rm2_out , rm2_dc1_out     , rm2_dc2_out     , rm2_dc3_out     , rm2_len , rm2_wth , rm3_out , rm3_dc1_out     , rm3_dc2_out     , rm3_dc3_out     , rm3_len , rm3_wth , rm4_out , rm4_dc1_out     , rm4_dc2_out     , rm4_dc3_out     , rm4_len , rm4_wth , rm5_out , rm5_dc1_out     , rm5_dc2_out     , rm5_dc3_out     , rm5_len , rm5_wth , rm6_out , rm6_dc1_out     , rm6_dc2_out     , rm6_dc3_out     , rm6_len , rm6_wth , rm7_out , rm7_dc1_out     , rm7_dc2_out     , rm7_dc3_out     , rm7_len , rm7_wth , rm8_out , rm8_dc1_out     , rm8_dc2_out     , rm8_dc3_out     , rm8_len , rm8_wth , rm9_out , rm9_dc1_out     , rm9_dc2_out     , rm9_dc3_out     , rm9_len , rm9_wth , rms     , rooms_plus      , s_r     , style   , yr      , taxes   , type_own1_out   , tour_url        , bath_tot)
;
"

echo "Load Resi data into New Server"
`$sqlcmd -e "$sql"`

#update city_id

echo "Update property_type"
sql="
update h_housetmp set city_id=3;
update h_housetmp set propertyType_id=1 where type_own1_out='Detached';
update h_housetmp set propertyType_id=2 where type_own1_out='Townhouse' or type_own1_out='Att/Row/Twnhouse' or type_own1_out='Triplex'
 or type_own1_out='Fourplex' or type_own1_out='Multiplex';
update h_housetmp set propertyType_id=4 where type_own1_out='Semi-Detached' or type_own1_out='Link' or type_own1_out='Duplex';
update h_housetmp set propertyType_id=5 where type_own1_out='Cottage' or type_own1_out='Rural Resid';
update h_housetmp set propertyType_id=6 where type_own1_out='Farm';
update h_housetmp set propertyType_id=7 where type_own1_out='Vacant Land';
"

`$sqlcmd -e "$sql"`

echo "`date`: Complete Load Resi Data into Maple City" >>$mlslog

#echo "`data`: load resi into local h_house table start">>$mlslog


