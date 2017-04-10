#!/bin/bash

########################
#Global  Parameter
########################
HOST='172.30.0.108'
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
piccount="/tmp/treb_pic_count.tmp"

mlslog="/home/ubuntu/log/mlslog.txt"


#################################
cd /mls



#
#DEBUG





################################################
#Load CSV into Table
sudo rm /tmp/resi.txt
sudo rm /tmp/condo.txt
sudo cat $vowresidata |sed 's/"//g' >/tmp/resi.txt 
sudo cat $vowcondodata |sed 's/"//g' >/tmp/condo.txt 
sudo chown mysql:mysql /tmp/resi.txt
sudo chown mysql:mysql /tmp/condo.txt
sudo chown mysql:mysql  $piccount
sudo chown mysql:mysql /tmp/idx.ml
echo "Load data into tables......."

loadcondo="
LOAD DATA INFILE '/tmp/condo.txt'  replace INTO TABLE vowcondo   FIELDS TERMINATED BY '|' 
(
A_c,Ad_text,Addr,Apt_num,Bath_tot,Br,Br_plus,Bsmt1_out,Bsmt2_out,Cable,Cac_inc,Cert_lvl,Comel_inc,Cond_txinc,Condo_corp,Condo_exp,Corp_num,County,Cross_st,Den_fr,Dom,Elevator,Ens_lndry,Energy_cert,Extras,Fpl_num,Fuel,Gar,Gar_type,Green_pis,Heat_inc,Heating,Handi_equipped,Hydro_inc,Insur_bldg,Level1,Level2,Level3,Level4,Level5,Level6,Level7,Level8,Level9,Locker,Locker_num,Lp_dol,Maint,Ml_num,Num_kit,Occ,Orig_dol,Outof_area,Parcel_id,Park_chgs,Park_desig,Park_fac,Park_spc1,Park_spc2,Park_spcs,Patio_ter,Pets,Prkg_inc,Rltr,Rm1_len,Rm1_out,Rm1_wth,Rm2_len,Rm2_out,Rm2_wth,Rm3_len,Rm3_out,Rm3_wth,Rm4_len,Rm4_out,Rm4_wth,Rm5_len,Rm5_out,Rm5_wth,Rm6_len,Rm6_out,Rm6_wth,Rm7_len,Rm7_out,Rm7_wth,Rm8_len,Rm8_out,Rm8_wth,Rm9_len,Rm9_out,Rm9_wth,Rms,Rooms_plus,S_r,Share_perc,Sqft,St,St_dir,St_num,St_sfx,Status,Stories,Style,Taxes,Tour_url,Tv,Uffi,Unit_num,Vend_pis,Water_inc,Wcloset_p1,Wcloset_p2,Wcloset_p3,Wcloset_p4,Wcloset_t1,Wcloset_t2,Wcloset_t3,Wcloset_t4,Yr,Yr_built,Zip,Zoning,Type_own_srch,Type_own1_out,Constr1_out,Constr2_out,Prop_feat1_out,Prop_feat2_out,Rm1_dc1_out,Rm1_dc2_out,Rm1_dc3_out,Rm2_dc1_out,Rm2_dc2_out,Rm2_dc3_out,Rm3_dc1_out,Rm3_dc2_out,Rm3_dc3_out,Rm4_dc1_out,Rm4_dc2_out,Rm4_dc3_out,Rm5_dc1_out,Rm5_dc2_out,Rm5_dc3_out,Rm6_dc1_out,Rm6_dc2_out,Rm6_dc3_out,Rm7_dc1_out,Rm7_dc2_out,Rm7_dc3_out,Rm8_dc1_out,Rm8_dc2_out,Rm8_dc3_out,Rm9_dc1_out,Rm9_dc2_out,Rm9_dc3_out,Ass_year,Vtour_updt,Disp_addr,Mmap_page,Mmap_col,Mmap_row,Prop_mgmt,All_inc,Furnished,Laundry,Pvt_ent,Central_vac,Kit_plus,Laundry_lev,Park_desig_2,Park_lgl_desc1,Park_lgl_desc2,Prop_feat3_out,Prop_feat4_out,Prop_feat5_out,Prop_feat6_out,Retirement,Rm10_dc1_out,Rm10_dc2_out,Rm10_dc3_out,Rm10_len,Rm10_out,Rm10_wth,Rm11_dc1_out,Rm11_dc2_out,Rm11_dc3_out,Rm11_len,Rm11_out,Rm11_wth,Rm12_dc1_out,Rm12_dc2_out,Rm12_dc3_out,Rm12_len,Rm12_out,Rm12_wth,Wcloset_p5,Wcloset_t1lvl,Wcloset_t2lvl,Wcloset_t3lvl,Wcloset_t4lvl,Wcloset_t5,Wcloset_t5lvl,Bldg_amen1_out,Bldg_amen2_out,Bldg_amen3_out,Bldg_amen4_out,Bldg_amen5_out,Bldg_amen6_out,Spec_des1_out,Spec_des2_out,Spec_des3_out,Spec_des4_out,Spec_des5_out,Spec_des6_out,Level10,Level11,Level12,Timestamp_sql,Area_code,Municipality_code,Community_code,Municipality_district,Area,Municipality,Community,Pix_updt,Oh_date1,Oh_from1,Oh_to1,Oh_date2,Oh_from2,Oh_to2,Oh_date3,Oh_from3,Oh_to3,Oh_dt_stamp)
;"

loadresi="
LOAD DATA INFILE '/tmp/resi.txt'  
replace INTO TABLE vowresi   
FIELDS TERMINATED BY '|' 
( A_c,Acres,Ad_text,Addr,Apt_num,Bath_tot,Br,Br_plus,Bsmt1_out,Bsmt2_out,Cable,Cac_inc,Cert_lvl,Comel_inc,Comp_pts,County,Cross_st,Den_fr,Depth,Dom,Drive,Elec,Elevator,Energy_cert,Extras,Farm_agri,Fpl_num,Front_ft,Fuel,Gar_type,Gas,Green_pis,Heat_inc,Heating,Handi_equipped,Hydro_inc,Irreg,Legal_desc,Level1,Level2,Level3,Level4,Level5,Level6,Level7,Level8,Level9,Lotsz_code,Lp_dol,Ml_num,Num_kit,Occ,Orig_dol,Outof_area,Parcel_id,Park_chgs,Park_spcs,Pool,Prkg_inc,Rltr,Rm1_len,Rm1_out,Rm1_wth,Rm2_len,Rm2_out,Rm2_wth,Rm3_len,Rm3_out,Rm3_wth,Rm4_len,Rm4_out,Rm4_wth,Rm5_len,Rm5_out,Rm5_wth,Rm6_len,Rm6_out,Rm6_wth,Rm7_len,Rm7_out,Rm7_wth,Rm8_len,Rm8_out,Rm8_wth,Rm9_len,Rm9_out,Rm9_wth,Rms,Rooms_plus,S_r,Sewer,Sqft,St,St_dir,St_num,St_sfx,Status,Style,Taxes,Tour_url,Tv,Uffi,Util_cable,Util_tel,Vend_pis,Water,Water_inc,Wcloset_p1,Wcloset_p2,Wcloset_p3,Wcloset_p4,Wcloset_t1,Wcloset_t2,Wcloset_t3,Wcloset_t4,Wtr_suptyp,Yr,Yr_built,Zip,Zoning,Type_own_srch,Type_own1_out,Constr1_out,Constr2_out,Prop_feat1_out,Prop_feat2_out,Oth_struc1_out,Oth_struc2_out,Rm1_dc1_out,Rm1_dc2_out,Rm1_dc3_out,Rm2_dc1_out,Rm2_dc2_out,Rm2_dc3_out,Rm3_dc1_out,Rm3_dc2_out,Rm3_dc3_out,Rm4_dc1_out,Rm4_dc2_out,Rm4_dc3_out,Rm5_dc1_out,Rm5_dc2_out,Rm5_dc3_out,Rm6_dc1_out,Rm6_dc2_out,Rm6_dc3_out,Rm7_dc1_out,Rm7_dc2_out,Rm7_dc3_out,Rm8_dc1_out,Rm8_dc2_out,Rm8_dc3_out,Rm9_dc1_out,Rm9_dc2_out,Rm9_dc3_out,Ass_year,Gar_spaces,Vtour_updt,Disp_addr,Mmap_page,Mmap_col,Mmap_row,All_inc,Furnished,Laundry,Lease_term,Pay_freq,Pvt_ent,Addl_mo_fee,Central_vac,Kit_plus,Laundry_lev,Prop_feat3_out,Prop_feat4_out,Prop_feat5_out,Prop_feat6_out,Retirement,Rm10_dc1_out,Rm10_dc2_out,Rm10_dc3_out,Rm10_len,Rm10_out,Rm10_wth,Rm11_dc1_out,Rm11_dc2_out,Rm11_dc3_out,Rm11_len,Rm11_out,Rm11_wth,Rm12_dc1_out,Rm12_dc2_out,Rm12_dc3_out,Rm12_len,Rm12_out,Rm12_wth,Waterfront,Wcloset_p5,Wcloset_t1lvl,Wcloset_t2lvl,Wcloset_t3lvl,Wcloset_t4lvl,Wcloset_t5,Wcloset_t5lvl,Spec_des1_out,Spec_des2_out,Spec_des3_out,Spec_des4_out,Spec_des5_out,Spec_des6_out,Level10,Level11,Level12,Timestamp_sql,Area_code,Municipality_code,Community_code,Municipality_district,Area,Municipality,Community,Pix_updt,Oh_date1,Oh_from1,Oh_to1,Oh_date2,Oh_from2,Oh_to2,Oh_date3,Oh_from3,Oh_to3,Oh_dt_stamp )
;"

loadpiccount="
LOAD DATA INFILE '/tmp/treb_pic_count.tmp'
replace INTO TABLE pic_num
FIELDS TERMINATED BY ','
"
/usr/bin/mysql -u $SQL_LOCAL_USER -p$SQL_LOCAL_PASS mls -e "$loadcondo"
/usr/bin/mysql -u $SQL_LOCAL_USER -p$SQL_LOCAL_PASS mls -e "$loadresi"
/usr/bin/mysql -u $SQL_LOCAL_USER -p$SQL_LOCAL_PASS mls -e "$loadpiccount"
#sudo rm $piccount
