#!/bin/bash

mlslog="/home/ubuntu/log/mlslog.txt"
phpdir="/home/ubuntu/script/crea/phRETS/PHRetsForCREA-master"
sqlcmd="mysql -u root -p19701029 mls"
msql="mysql -u hdm106787551 -h  alinew -pMaplemYsql100 --local-infile  hdm106787551_db "
csvfile="/tmp/crea.update"
active="/tmp/crea_active"
creastats="/tmp/creastats"

function download_crea  {

sudo rm $csvfile $active
#Download incremental CREA
echo "Download CREA Meta Data...."
echo "`date`: Start Download CREA Meta " >>$mlslog
php -f $phpdir/download.php >$csvfile
count=`wc -l < $csvfile`
echo "`date`: Download CREA Complete - $count" >>$mlslog

#Update stats table

echo "update:$count" >$creastats


echo "Download CREA Active List"
#Download active listing

echo "`date`: Start downloading CREA ACTIVE" >>$mlslog
php -f $phpdir/download_active.php >$active
count=`wc -l $active`
echo "`date`: Download CREA ACTIVE Complete - $count" >>$mlslog
echo "total:$count" >>$creastats

}

#Function to import CREA data into crea table
#
function load_crea_table {

sudo chown mysql:mysql $csvfile
#Load New Data
sql="

LOAD DATA infile \"$csvfile\"
replace INTO TABLE crea
fields terminated BY \"|\"

(
id,maint,ml_num,addr,a_c,yr_built,sqft,bsmt1_out,bsmt2_out,br,constr1_out,fpl_num,gar_spaces,fuel,heating,level1,rm1_out,rm1_len,rm1_wth,level2,rm2_out,rm2_len,rm2_wth,level3,rm3_out,rm3_len,rm3_wth,level4,rm4_out,rm4_len,rm4_wth,level5,rm5_out,rm5_len,rm5_wth,level6,rm6_out,rm6_len,rm6_wth,level7,rm7_out,rm7_len,rm7_wth,level8,rm8_out,rm8_len,rm8_wth,level9,rm9_out,rm9_len,rm9_wth,level10,rm10_out,rm10_len,rm10_wth,level11,rm11_out,rm11_len,rm11_wth,level12,rm12_out,rm12_len,rm12_wth,lp_dol,municipality,zip,county,prop_feat1_out,prop_feat2_out,prop_feat3_out,prop_feat4_out,ad_text,s_r,style,bath_tot,type_own1_out,community,comp_pts,land_area,acres,pix_updt,pool,central_vac,tour_url,num_kit
);

"

echo "Load CREA CSV into crea table...."
`$sqlcmd -e "$sql"`
echo "`date`: Load CREA CSV into CREA Table Complete" >>$mlslog
}

function compare_crea_active {

echo "Compare active ID with list in crea table"
tmpfile="/tmp/crea_mls"
sudo rm /tmp/crea.delete
if [ -s $active ]
then
        echo "Reconsile CREA Active with CREA Table"
        mysql -u root -p19701029 -N -B mls -e 'select id from crea' > $tmpfile
		cat $active >> $tmpfile
        sort $tmpfile |uniq -c|grep "1 "|awk '{print $2}' | while read line
        do
        echo "delete from crea where id='$line';" >> /tmp/crea.delete
        done
	echo "Delete inactive listing from crea table...."	
	`$sqlcmd </tmp/crea.delete`
	count=`wc -l /tmp/crea.delete`
	echo "`date`: Compare Active  CREA  ID and CREA Table Complete Delete $count records" >>$mlslog
	echo "delete:$count" >>$creastats

fi


}


function generate_latlon {

echo "Generate lat and lon"
mapfile="/tmp/creamap.csv"
latlonfile="/tmp/crealatlng.txt"

#Export Address List
exportloc="
select
ml_num ,
addr    ,
municipality    ,
county,
zip ,
'Canada'
FROM crea
WHERE ml_num not in (select ml_num from location)
INTO OUTFILE '/tmp/creamap.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

echo "export CREA address into tmp file"
sudo rm $mapfile
`$sqlcmd -e "$exportloc"`
count=`wc -l $mapfile`
#create new house file
cat $mapfile >/tmp/newhouse.csv
echo "`date`:  CREA  for Google Map API - $count"
echo "`date`:  Export CREA List for Google Map API - $count" >>$mlslog



#Prepare Google GeoLocation API

cd /tmp
geoapi="https://maps.googleapis.com/maps/api/geocode/json?address="
#Key for freelife project
#key="AIzaSyAWB8vpdbzBZGt43jHqdxm1n6z6-516dQo"
#Key for maplecity project
key="AIzaSyBGJcQ82UD7-0p-O1kAXjiPiAaSUWkpi2w"

[ -f $latlonfile ] && sudo rm $latlonfile
[ -f results.json ] && rm results.json

while read line; do
    address=`cut -d"|" -f2-6 <<<$line | tr '|' '+' | tr ' ' '+'`
    mls=`cut -d"|" -f1 <<<$line`
    curl "$geoapi$address&key=$key" -o results.json
    #echo  "$mls       $geoapi$address&key=$key" 
    # Parse json with jshon (http://kmkeen.com/jshon/)
    location=`jshon -e results -a -e geometry -e location -e "lat" -u -p -e "lng" -u < results.json | head -2 | paste -d, - - `
     #Generate location CSV
    echo $mls,$location >> $latlonfile
    #sleep 10
done < $mapfile

cp /tmp/map.csv >/tmp/newhouse.txt


echo "Load location file into table"

loadsql="LOAD DATA INFILE \"$latlonfile\"  ignore INTO TABLE location   FIELDS TERMINATED BY ',' ;"
sudo chown mysql:mysql $latlonfile

count=`wc -l $latlonfile`

`$sqlcmd -e "$loadsql"`
echo "`date`:  Load Lat/Lon into Location Table - $count" >>$mlslog



}

function export_crea_table {


#Export  CREA CSV for LOADING
exportcrea="
select 
'CREA',
pic.pic_num,
maint,
propertytype_id,
land_area,
acres,
p.id , 
l.lat ,
l.lon ,
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
crea.ml_num	,
municipality	,
municipality_code	,
pix_updt ,
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
rm1_len/3.28	,
rm1_wth/3.28	,
rm10_out	,
rm10_dc1_out	,
rm10_dc2_out	,
rm10_dc3_out	,
rm10_len/3.28	,
rm10_wth/3.28	,
rm11_out	,
rm11_dc1_out	,
rm11_dc2_out	,
rm11_dc3_out	,
rm11_len/3.28	,
rm11_wth/3.28	,
rm12_out	,
rm12_dc1_out	,
rm12_dc2_out	,
rm12_dc3_out	,
rm12_len/3.28	,
rm12_wth/3.28	,
rm2_out	,
rm2_dc1_out	,
rm2_dc2_out	,
rm2_dc3_out	,
rm2_len/3.28	,
rm2_wth/3.28	,
rm3_out	,
rm3_dc1_out	,
rm3_dc2_out	,
rm3_dc3_out	,
rm3_len/3.28	,
rm3_wth/3.28	,
rm4_out	,
rm4_dc1_out	,
rm4_dc2_out	,
rm4_dc3_out	,
rm4_len/3.28	,
rm4_wth/3.28	,
rm5_out	,
rm5_dc1_out	,
rm5_dc2_out	,
rm5_dc3_out	,
rm5_len/3.28	,
rm5_wth/3.28	,
rm6_out	,
rm6_dc1_out	,
rm6_dc2_out	,
rm6_dc3_out	,
rm6_len/3.28	,
rm6_wth/3.28	,
rm7_out	,
rm7_dc1_out	,
rm7_dc2_out	,
rm7_dc3_out	,
rm7_len/3.28	,
rm7_wth/3.28	,
rm8_out	,
rm8_dc1_out	,
rm8_dc2_out	,
rm8_dc3_out	,
rm8_len/3.28	,
rm8_wth/3.28	,
rm9_out	,
rm9_dc1_out	,
rm9_dc2_out	,
rm9_dc3_out	,
rm9_len/3.28	,
rm9_wth/3.28	,
br	,
bath_tot	,
s_r	,
style	,
yr	,
taxes	,
type_own1_out	,
tour_url	,
bath_tot	
FROM crea 
LEFT JOIN location l
ON crea.ml_num = l.ml_num
LEFT JOIN province p
ON crea.county = p.name
LEFT JOIN pic_num pic
ON crea.ml_num = pic.ml_num
INTO OUTFILE '/tmp/crea_house.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"



sudo rm /tmp/crea_house.csv*
echo "Export CREA Table for MaplyCity H_house"
`$sqlcmd -e "$exportcrea"`

#echo "`date`: Resi Date for Import - `wc -l /tmp/resi.csv`" >>$mlslog


#Load Data into maplecity table


#echo "Load SQL into Maplecity DB"
#Load this after TREB data is loaded -export_condo.sh
#`$msql -e "$sql"`


}

function data_trans {

echo "Start Data Tranform"


#Transform propery type


sql="
update crea set propertytype_id=8 ;
update crea set propertyType_id=1 where type_own1_out in ('Detached','House');
update crea set propertyType_id=2 where type_own1_out in ('Attached' ,'Link','Row / Townhouse','Triplex','Fourplex','Multiplex');
update crea set propertyType_id=4 where type_own1_out in ('Semi-Detached','Duplex');
update crea set propertyType_id=3 where type_own1_out='Apartment';
update crea set propertyType_id=7 where type_own1_out='Vacant Land';

"
echo "Update propertyType_id...."
`$sqlcmd -e "$sql"`

}
#Step 1
download_crea 

#Load crea csv into crea table (READY)
load_crea_table

#Reconsile (READY)
compare_crea_active

#generate LAT/LON
generate_latlon

#Data Transform (READY)
data_trans

#Export CSV
export_crea_table


echo "`date`: Load_CREA Script Complete" >>$mlslog
