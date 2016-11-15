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
FROM vowcondo
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

echo "`date`: Export Condo MLS for Google Map API - $count" >>$mlslog





#Prepare Google GeoLocation API

cd /tmp
geoapi="https://maps.googleapis.com/maps/api/geocode/json?address="
key="AIzaSyAWB8vpdbzBZGt43jHqdxm1n6z6-516dQo"

##Start Google API
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


#Load location file into table

echo "Load Condo location file into table"

loadsql="LOAD DATA INFILE '/tmp/latlng.txt'  ignore INTO TABLE location   FIELDS TERMINATED BY ',' ;"
sudo chown mysql:mysql /tmp/latlng.txt
/usr/bin/mysql -u root -p$pass mls -e "$loadsql"

#End Google Map Location 


#Export CSV for LOADING
exportresi="
select  
pic_num.pic_num,
apt_num,
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
maint,
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
'E'	,
furnished	,
'0'	,
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
'0'	,
'0'	,
'Feet'	,
vowcondo.ml_num	,
municipality	,
municipality_code	,
timestamp_sql ,
'NA'	,
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
FROM vowcondo
left join location on vowcondo.ml_num = location.ml_num
left join pic_num  on vowcondo.ml_num = pic_num.ml_num
WHERE vowcondo.county ='Ontario' AND vowcondo.ml_num REGEXP '[a-z][0-9].*' 
INTO OUTFILE '/tmp/condo.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

sudo rm /tmp/condo.csv*
echo "Export MLS Condo Table for MaplyCity H_house"
/usr/bin/mysql -u root -p19701029 mls -e "$exportresi"
echo "`date`: Condo Date for Import - `wc -l /tmp/condo.csv`" >>$mlslog

#sudo gzip /tmp/condo.csv


#echo "SCP CSV to Ali Server...."
#ssh root@ali rm  /tmp/condo.csv
#scp /tmp/condo.csv.gz root@ali:/tmp/condo.csv.gz
#sleep 10
#echo "`date` :Unzip Condo CSV File" 
#ssh root@ali gzip -d /tmp/condo.csv.gz


#Load Data into maplecity table

#echo "Load Condo Data into Maplecity DB"
#ssh root@ali /root/script/loadcondo.sh
echo "Load Condo Data into New MapleCity Server"



sqlcmd="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "


#Load New Data
sql="

LOAD DATA LOCAL infile '/tmp/condo.csv'
INTO TABLE h_housetmp
fields terminated BY \"|\"

(
pic_num, apt_num, orig_dol, oh_date1, oh_from1, oh_to1, oh_date2, oh_from2, oh_to2, oh_date3, oh_from3, oh_to3, dom, src,prepay,latitude,longitude, addr    , a_c     , yr_built        , sqft    , area    , area_code       , bsmt1_out       , bsmt2_out       , br      , br_plus , central_vac     , community       , community_code  , cross_st        , elevator        , constr1_out     , constr2_out     , extras  , fpl_num , comp_pts        , furnished       , gar_spaces      , fuel    , heating , num_kit , kit_plus        , level1  , level10 , level11 , level12 , level2  , level3  , level4  , level5  , level6  , level7  , level8  , level9  , lp_dol  , depth   , front_ft        , lotsz_code      , ml_num  , municipality    , municipality_code       , pix_updt        , pool    , zip    , prop_feat1_out  , prop_feat2_out  , prop_feat3_out  , prop_feat4_out  , prop_feat5_out  , prop_feat6_out  , county  , ad_text , rm1_out , rm1_dc1_out     , rm1_dc2_out     , rm1_dc3_out     , rm1_len , rm1_wth , rm10_out        , rm10_dc1_out    , rm10_dc2_out    , rm10_dc3_out    , rm10_len        , rm10_wth        , rm11_out        , rm11_dc1_out    , rm11_dc2_out    , rm11_dc3_out    , rm11_len        , rm11_wth        , rm12_out        , rm12_dc1_out    , rm12_dc2_out    , rm12_dc3_out    , rm12_len        , rm12_wth        , rm2_out , rm2_dc1_out     , rm2_dc2_out     , rm2_dc3_out     , rm2_len , rm2_wth , rm3_out , rm3_dc1_out     , rm3_dc2_out     , rm3_dc3_out     , rm3_len , rm3_wth , rm4_out , rm4_dc1_out     , rm4_dc2_out     , rm4_dc3_out     , rm4_len , rm4_wth , rm5_out , rm5_dc1_out     , rm5_dc2_out     , rm5_dc3_out     , rm5_len , rm5_wth , rm6_out , rm6_dc1_out     , rm6_dc2_out     , rm6_dc3_out     , rm6_len , rm6_wth , rm7_out , rm7_dc1_out     , rm7_dc2_out     , rm7_dc3_out     , rm7_len , rm7_wth , rm8_out , rm8_dc1_out     , rm8_dc2_out     , rm8_dc3_out     , rm8_len , rm8_wth , rm9_out , rm9_dc1_out     , rm9_dc2_out     , rm9_dc3_out     , rm9_len , rm9_wth , rms     , rooms_plus      , s_r     , style   , yr      , taxes   , type_own1_out   , tour_url        , bath_tot)
;
"

`$sqlcmd -e "$sql"`


echo "Update City_ID/Property_Type"
sql="
update h_housetmp set city_id=3 where county=\"Ontario\";
update h_housetmp set propertytype_id=8 where propertytype_id='';
update h_housetmp set propertyType_id=1 where type_own1_out='Detached';
update h_housetmp set propertyType_id=2 where type_own1_out in ('Townhouse' ,'Att/Row/Twnhouse','Triplex','Fourplex','Multiplex');
update h_housetmp set propertyType_id=4 where type_own1_out in ('Semi-Detached','Link','Duplex');
update h_housetmp set propertyType_id=3 where type_own1_out like 'Co%';
update h_housetmp set propertyType_id=5 where type_own1_out in ('Cottage','Rural Resid');
update h_housetmp set propertyType_id=6 where type_own1_out='Farm';
update h_housetmp set propertyType_id=7 where type_own1_out='Vacant Land';
update h_housetmp h join h_district d on h.area=d.englishName set h.district_id = d.id;
update h_housetmp set community = replace(community,\"'\",\"-\");
update h_housetmp set yr_built=\"6-15\" where yr_built=\"6-10\";
update h_housetmp set yr_built=\"6-15\" where yr_built=\"11-15\";
"
`$sqlcmd -e "$sql"`



#Update Stats Table

echo "Update Stats Table"
stats_file="/tmp/stats"
t_resi=`grep t_resi $stats_file|cut -d: -f2`
t_condo=`grep t_condo $stats_file|cut -d: -f2`
u_resi=`grep u_resi $stats_file|cut -d: -f2`
u_condo=`grep u_condo $stats_file|cut -d: -f2`

csvfile="/tmp/crea.update"
count=`wc -l < $csvfile`

sql="
INSERT INTO  h_stats (
date ,
t_resi ,
t_condo ,
u_resi ,
u_condo ,
u_house
)
VALUES (
CURRENT_DATE( ) ,  $t_resi,  $t_condo, $u_resi,  $u_condo , $count
);
"
`$sqlcmd -e "$sql"`

#Generate average price

sql="
update h_stats set avg_price = (select avg(lp_dol) from h_housetmp where s_r='Sale' and lp_dol > 1000) where date=CURRENT_DATE( ); 
"
`$sqlcmd -e "$sql"`

#Load CREA Data

msql="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "

count=`wc -l /tmp/crea_house.csv`
echo "`date` SSH Copy CREA Export into Maplecity DB $count"
echo "`date` SSH Copy CREA Export into Maplecity DB $count" >>$mlslog

sudo cp /tmp/crea_house.csv /tmp/crea_house.csv.today
sudo rm /tmp/crea_house.csv.gz
sudo gzip  /tmp/crea_house.csv
scp /tmp/crea_house.csv.gz dzheng@alinew:/tmp/crea.csv.gz

echo "`date` Start Load CREA Export into Maplecity DB $count" >>$mlslog
#`$sqlcmd -e "$sql"`
ssh dzheng@alinew /home/dzheng/script/load_crea.sh
echo "`date` End Load CREA Export into Maplecity DB $count" >>$mlslog

count=`wc -l /tmp/newhouse.csv`
echo "`date` Generate new house list: $count" >>$mlslog
awk  -F"|" '{print $1}' /tmp/newhouse.csv >/tmp/newhouse.mls

#Update stats chart table

`$sqlcmd  <$scriptdir/house_update.sql`

echo "`date` End SQL House Update" >>$mlslog
