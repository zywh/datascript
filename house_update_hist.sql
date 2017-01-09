

#Update CREA Stats

#Generate Recommend List
UPDATE h_housetmp set recommend=1 
WHERE propertyType_id=1 AND 
lp_dol > 800000 AND lp_dol < 1200000 AND bath_tot > 3;


#Generate Data for CITY CHART

#Update IDX house SRC flag
update h_housetmp,idx_mls set h_housetmp.src="IDX" where h_housetmp.ml_num = idx_mls.ml_num;

#stats

#insert into h_house_price_hist select substr(zip,1,3),floor(avg(lp_dol)),count(*),date(now()) from h_housetmp group by substr(zip,1,3) ;


insert into h_house_price_hist select substr(zip,1,3),floor(avg(lp_dol)),count(*),date(now()),s_r,propertyType_id,municipality,county from h_housetmp group by substr(zip,1,3),propertyType_id,s_r ; 
