#Fix Pool
update h_housetmp set pool='Inground pool' where pool='Inground';
update h_housetmp set pool='pool' where pool='Pool';
update h_housetmp set pool='Indoor pool' where pool='Indoor';
update h_housetmp set pool='Above ground pool' where pool='Abv Grnd';

#Fix pix_updt
update h_housetmp set  pix_updt = DATE_SUB(now(),INTERVAL 5 DAY) where pix_updt > date(now());


#Update Land Size from TREB Data using depthxfront_ft
#
update h_housetmp set land_area=depth* front_ft where front_ft > 0 ;
update h_housetmp set land_area=depth* front_ft*10.76 where front_ft > 0 and lotsz_code ='Metres';
update h_housetmp set land_area=front_ft*43560 where front_ft > 0 and lotsz_code ='Acres';
update h_housetmp set acres=concat(depth,'x',front_ft,' ',lotsz_code) where front_ft > 0;

#Update SQFT
#update h_housetmp set house_area = sqft ;
update ignore h_housetmp set house_area = convert(sqft,UNSIGNED INTEGER) ;
update ignore h_housetmp set house_area = house_area * 10.76 where sqft like '%m%' ;
#update h_housetmp set sqft = round(house_area) where sqft like '%m%' ;
#update h_housetmp set sqft = round(house_area) where sqft like '%sq%' ;
#Default Province
update h_housetmp set city_id='100'  where city_id is NULL;


#Update CREA Stats

#Generate Recommend List
UPDATE h_housetmp set recommend=1 
WHERE propertyType_id=1 AND 
lp_dol > 800000 AND lp_dol < 1200000 AND bath_tot > 3;


#Generate Data for CITY CHART

#Update IDX house SRC flag
update h_housetmp,idx_mls set h_housetmp.src="IDX" where h_housetmp.ml_num = idx_mls.ml_num;

#update contract date

update h_housetmp set pix_updt=date_sub(now(),INTERVAL datediff(now(), pix_updt) + dom-1  DAY ) where src !='CREA' and pix_updt< date(now());
update h_housetmp set pix_updt=date_sub(now(),INTERVAL datediff(now(), pix_updt) + dom  DAY ) where src !='CREA' and pix_updt = date(now());


#stats

#insert into h_house_price_hist select substr(zip,1,3),floor(avg(lp_dol)),count(*),date(now()) from h_housetmp group by substr(zip,1,3) ;


insert into h_house_price_hist select substr(zip,1,3),floor(avg(lp_dol)),count(*),date(now()),s_r,propertyType_id,municipality,county from h_housetmp group by substr(zip,1,3),propertyType_id,s_r ; 
