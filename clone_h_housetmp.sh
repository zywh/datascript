#!/bin/bash


mlslog="/home/ubuntu/log/mlslog.txt"
scriptdir="/home/ubuntu/script"
sqlcmd="/usr/bin/mysql -u root -p19701029 mls "
resicsv="/tmp/resi.csv"
condocsv="/tmp/condo.csv"
creacsv="/tmp/crea_house.csv.today"


echo "`date`:  Load Resi Data into local h_house" >>$mlslog

sudo chown mysql:mysql $resicsv
#Load New Data
sql="
delete from h_housetmp;

LOAD DATA infile '$resicsv'
INTO TABLE h_housetmp
fields terminated BY \"|\"

(
pic_num, orig_dol, oh_date1, oh_from1, oh_to1, oh_date2, oh_from2, oh_to2, oh_date3, oh_from3, oh_to3, dom, src,latitude,longitude, addr    , a_c     , yr_built        , sqft    , area    , area_code       , bsmt1_out       , bsmt2_out       , br      , br_plus , central_vac     , community       , community_code  , cross_st        , elevator        , constr1_out     , constr2_out     , extras  , fpl_num , comp_pts        , furnished       , gar_spaces      , fuel    , heating , num_kit , kit_plus        , level1  , level10 , level11 , level12 , level2  , level3  , level4  , level5  , level6  , level7  , level8  , level9  , lp_dol  , depth   , front_ft        , lotsz_code      , ml_num  , municipality    , municipality_code       , pix_updt        , pool    , zip    , prop_feat1_out  , prop_feat2_out  , prop_feat3_out  , prop_feat4_out  , prop_feat5_out  , prop_feat6_out  , county  , ad_text , rm1_out , rm1_dc1_out     , rm1_dc2_out     , rm1_dc3_out     , rm1_len , rm1_wth , rm10_out        , rm10_dc1_out    , rm10_dc2_out    , rm10_dc3_out    , rm10_len        , rm10_wth        , rm11_out        , rm11_dc1_out    , rm11_dc2_out    , rm11_dc3_out    , rm11_len        , rm11_wth        , rm12_out        , rm12_dc1_out    , rm12_dc2_out    , rm12_dc3_out    , rm12_len        , rm12_wth        , rm2_out , rm2_dc1_out     , rm2_dc2_out     , rm2_dc3_out     , rm2_len , rm2_wth , rm3_out , rm3_dc1_out     , rm3_dc2_out     , rm3_dc3_out     , rm3_len , rm3_wth , rm4_out , rm4_dc1_out     , rm4_dc2_out     , rm4_dc3_out     , rm4_len , rm4_wth , rm5_out , rm5_dc1_out     , rm5_dc2_out     , rm5_dc3_out     , rm5_len , rm5_wth , rm6_out , rm6_dc1_out     , rm6_dc2_out     , rm6_dc3_out     , rm6_len , rm6_wth , rm7_out , rm7_dc1_out     , rm7_dc2_out     , rm7_dc3_out     , rm7_len , rm7_wth , rm8_out , rm8_dc1_out     , rm8_dc2_out     , rm8_dc3_out     , rm8_len , rm8_wth , rm9_out , rm9_dc1_out     , rm9_dc2_out     , rm9_dc3_out     , rm9_len , rm9_wth , rms     , rooms_plus      , s_r     , style   , yr      , taxes   , type_own1_out   , tour_url        , bath_tot)
;
"

`$sqlcmd -e "$sql"`

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

echo "`date`: Complete Load Resi Data into Local Table" >>$mlslog

#Load New Data
sudo chown mysql:mysql $condocsv
sql="

LOAD DATA infile '$condocsv'
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
#update h_housetmp h join h_district d on h.area=d.englishName set h.district_id = d.id;
update h_housetmp set community = replace(community,\"'\",\"-\");
update h_housetmp set yr_built=\"6-15\" where yr_built=\"6-10\";
update h_housetmp set yr_built=\"6-15\" where yr_built=\"11-15\";
"
`$sqlcmd -e "$sql"`


#`$sqlcmd  <$scriptdir/house_update.sql`

echo "`date` End SQL Local CONDO House Update" >>$mlslog
echo "`date` Start SQL Local CREA House Update" >>$mlslog
sql="
LOAD DATA  infile '$creacsv'
IGNORE INTO TABLE h_housetmp
fields terminated BY \"|\"
(src,pic_num,prepay,propertytype_id,land_area,acres,city_id, latitude,longitude, addr    , a_c     , yr_built        , sqft    , area    , area_code       , bsmt1_out , bsmt2_out       , br      , br_plus , central_vac     , community       , community_code  , cross_st        , elevator        , constr1_out     , constr2_out     , extras  , fpl_num , comp_pts        , furnished       , gar_spaces      , fuel    , heating , num_kit , kit_plus        , level1  , level10 , level11 , level12 , level2  , level3  , level4  , level5  , level6  , level7  , level8  , level9  , lp_dol  , depth   , front_ft        , lotsz_code      , ml_num  , municipality    , municipality_code , pix_updt        , pool    , zip    , prop_feat1_out  , prop_feat2_out  , prop_feat3_out  , prop_feat4_out  , prop_feat5_out  , prop_feat6_out  , county  , ad_text , rm1_out , rm1_dc1_out     , rm1_dc2_out     , rm1_dc3_out     , rm1_len , rm1_wth , rm10_out        , rm10_dc1_out    , rm10_dc2_out    , rm10_dc3_out    , rm10_len        , rm10_wth        , rm11_out        , rm11_dc1_out    , rm11_dc2_out    , rm11_dc3_out    , rm11_len        , rm11_wth        , rm12_out        , rm12_dc1_out    , rm12_dc2_out , rm12_dc3_out    , rm12_len        , rm12_wth        , rm2_out , rm2_dc1_out     , rm2_dc2_out     , rm2_dc3_out     , rm2_len , rm2_wth , rm3_out , rm3_dc1_out     , rm3_dc2_out     , rm3_dc3_out     , rm3_len , rm3_wth , rm4_out , rm4_dc1_out     , rm4_dc2_out     , rm4_dc3_out     , rm4_len , rm4_wth , rm5_out , rm5_dc1_out     , rm5_dc2_out     , rm5_dc3_out     , rm5_len , rm5_wth , rm6_out , rm6_dc1_out     , rm6_dc2_out     , rm6_dc3_out     , rm6_len , rm6_wth , rm7_out , rm7_dc1_out     , rm7_dc2_out     , rm7_dc3_out     , rm7_len , rm7_wth , rm8_out , rm8_dc1_out     , rm8_dc2_out     , rm8_dc3_out     , rm8_len , rm8_wth , rm9_out , rm9_dc1_out     , rm9_dc2_out , rm9_dc3_out     , rm9_len , rm9_wth , rms     , rooms_plus      , s_r     , style   , yr      , taxes   , type_own1_out   , tour_url        , bath_tot) ;
"

sudo chown mysql:mysql $creacsv
`$sqlcmd -e "$sql"`
echo "`date` End SQL Local CREA House Update" >>$mlslog

`$sqlcmd  <$scriptdir/house_update_local.sql`

#export house table for clouse server
echo "`date`:  Start Sync h_house table to Google server" >>$mlslog
mysqldump -u root -p19701029 mls h_housetmp | gzip >/tmp/current_housetmp.sql.gz
scp /tmp/current_housetmp.sql.gz g1:
ssh g1 "/home/ubuntu/script/restore_table.sh"
echo "`date`:  End Sync h_house table to Google server" >>$mlslog
