#!/bin/bash


sqlcmd="mysql -u hdm106787551 -h  hdm106787551.my3w.com -pMaplemYsql100 --local-infile  hdm106787551_db "
#sqlcmd1="mysql -u mlsadmin -h  freelifewm.com -p19701029 --local-infile  mls "



#exit 0
#Empty h_house table
sql="delete from h_house;"
`$sqlcmd -e "$sql"`

#Load New Data
sql="

LOAD DATA LOCAL infile '/tmp/resi.csv'
INTO TABLE h_house
fields terminated BY \"|\"

(house_image, latitude,longitude, addr    , a_c     , yr_built        , sqft    , area    , area_code       , bsmt1_out       , bsmt2_out       , br      , br_plus , central_vac     , community       , community_code  , cross_st        , elevator        , constr1_out     , constr2_out     , extras  , fpl_num , comp_pts        , furnished       , gar_spaces      , fuel    , heating , num_kit , kit_plus        , level1  , level10 , level11 , level12 , level2  , level3  , level4  , level5  , level6  , level7  , level8  , level9  , lp_dol  , depth   , front_ft        , lotsz_code      , ml_num  , municipality    , municipality_code       , pix_updt        , pool    , zip    , prop_feat1_out  , prop_feat2_out  , prop_feat3_out  , prop_feat4_out  , prop_feat5_out  , prop_feat6_out  , county  , ad_text , rm1_out , rm1_dc1_out     , rm1_dc2_out     , rm1_dc3_out     , rm1_len , rm1_wth , rm10_out        , rm10_dc1_out    , rm10_dc2_out    , rm10_dc3_out    , rm10_len        , rm10_wth        , rm11_out        , rm11_dc1_out    , rm11_dc2_out    , rm11_dc3_out    , rm11_len        , rm11_wth        , rm12_out        , rm12_dc1_out    , rm12_dc2_out    , rm12_dc3_out    , rm12_len        , rm12_wth        , rm2_out , rm2_dc1_out     , rm2_dc2_out     , rm2_dc3_out     , rm2_len , rm2_wth , rm3_out , rm3_dc1_out     , rm3_dc2_out     , rm3_dc3_out     , rm3_len , rm3_wth , rm4_out , rm4_dc1_out     , rm4_dc2_out     , rm4_dc3_out     , rm4_len , rm4_wth , rm5_out , rm5_dc1_out     , rm5_dc2_out     , rm5_dc3_out     , rm5_len , rm5_wth , rm6_out , rm6_dc1_out     , rm6_dc2_out     , rm6_dc3_out     , rm6_len , rm6_wth , rm7_out , rm7_dc1_out     , rm7_dc2_out     , rm7_dc3_out     , rm7_len , rm7_wth , rm8_out , rm8_dc1_out     , rm8_dc2_out     , rm8_dc3_out     , rm8_len , rm8_wth , rm9_out , rm9_dc1_out     , rm9_dc2_out     , rm9_dc3_out     , rm9_len , rm9_wth , rms     , rooms_plus      , s_r     , style   , yr      , taxes   , type_own1_out   , tour_url        , bath_tot)
;
"

`$sqlcmd -e "$sql"`
#update city_id
echo "Update City_ID"
sql="update h_house set city_id=3;"
`$sqlcmd -e "$sql"`

echo "Update property_type"
sql="update h_house set propertyType_id=1 where type_own1_out='Detached';
update h_house set propertyType_id=2 where type_own1_out='Townhouse' or type_own1_out='Att∕Row∕Twnhouse' or type_own1_out='Triplex'
 or type_own1_out='Fourplex' or type_own1_out='Multiplex';
update h_house set propertyType_id=4 where type_own1_out='Semi-Detached' or type_own1_out='Link' or type_own1_out='Duplex';
update h_house set propertyType_id=5 where type_own1_out='Cottage' or type_own1_out='Rural Resid';
update h_house set propertyType_id=6 where type_own1_out='Farm';
update h_house set propertyType_id=7 where type_own1_out='Vacant Land';"

`$sqlcmd -e "$sql"`

