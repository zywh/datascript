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
update ignore h_housetmp set house_area = convert(sqft,UNSIGNED INTEGER) ;
update ignore h_housetmp set house_area = house_area * 10.76 where sqft like '%m%' ;
#Default Province
update h_housetmp set city_id='100'  where city_id is NULL;








