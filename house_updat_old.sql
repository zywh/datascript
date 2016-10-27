#Fix Pool
update h_house set pool='Inground pool' where pool='Inground';
update h_house set pool='pool' where pool='Pool';
update h_house set pool='Indoor pool' where pool='Indoor';
update h_house set pool='Above ground pool' where pool='Abv Grnd';

#Update Land Size from TREB Data using depthxfront_ft
#
update h_house set land_area=depth* front_ft where front_ft > 0 ;
update h_house set land_area=depth* front_ft*10.76 where front_ft > 0 and lotsz_code ='Metres';
update h_house set land_area=front_ft*43560 where front_ft > 0 and lotsz_code ='Acres';
update h_house set acres=concat(depth,'x',front_ft,' ',lotsz_code) where front_ft > 0;

#Update SQFT
update h_house set house_area = sqft ;
update h_house set house_area = house_area * 10.76 where sqft like '%m%' ;
update h_house set sqft = round(house_area) where sqft like '%m%' ;
update h_house set sqft = round(house_area) where sqft like '%sq%' ;
#Default Province
update h_house set city_id='100'  where city_id is NULL;


#Update CREA Stats
UPDATE h_stats set avg_house = (select avg(lp_dol) from h_house where s_r='Sale' and lp_dol > 1000) where date=CURRENT_DATE( );
UPDATE h_stats set t_house = (select count(*) from h_house ) where date=CURRENT_DATE( );

#Generate Recommend List
UPDATE h_house set recommend=1 
WHERE propertyType_id=1 AND 
lp_dol > 800000 AND lp_dol < 1200000 AND bath_tot > 3;


#Generate Data for CITY CHART
delete from h_stats_chart where chartname='city';
INSERT h_stats_chart (chartname,n1,n3,i1,i2,n4,n2)
SELECT 'city', m.municipality_cname as cname, h.municipality as ename,
count(*) as count,round(avg(lp_dol/10000)) as price_avg,
h.county province, c.name as provincec
FROM h_house h,h_mname m,h_city c
WHERE h.municipality = m.municipality
AND h.county = c.englishname
GROUP BY h.municipality  HAVING count > 50
order by count desc;

#Generate Data for Province CHART
delete from h_stats_chart where chartname='province';
INSERT h_stats_chart (chartname,i1,i2,n4,n2)
SELECT 'province', count(*) as count,round(avg(lp_dol/10000)) as price_avg,
h.county province, c.name as provincec
FROM h_house h,h_city c
WHERE h.county = c.englishname
AND h.county !='' 
GROUP BY h.county 
order by count desc;


#Generate Data for Type Chart
delete from h_stats_chart where chartname='type';
INSERT h_stats_chart (chartname,i1,n1,i2)
SELECT 'type',count(*) as count,p.name as cname, round(avg(lp_dol/10000))
FROM h_house h,h_property_type p 
WHERE h.propertytype_id = p.id group by h.propertytype_id ;


#Generate Data for Price Chart
delete from h_stats_chart where chartname='price';
INSERT h_stats_chart (chartname,n1,i1)
SELECT 'price',floor(lp_dol/200000)*20 as bin, count(*) as count
from h_house 
where lp_dol > 100 and s_r ='Sale' and lp_dol < 4000000
group by bin ;


#Generate Data for House Area Chart
delete from h_stats_chart where chartname='house';
INSERT h_stats_chart (chartname,n1,i1)
SELECT 'house',floor(house_area/500)*500 as bin, count(*) as count
from h_house 
where house_area > 100 and house_area < 6000 
group by bin ;



#Generate Data for Land Area Chart
delete from h_stats_chart where chartname='land';
INSERT h_stats_chart (chartname,n1,i1)
SELECT 'land',floor(land_area/1000)*1000 as bin, count(*) as count
from h_house 
where land_area > 100 and land_area < 20000 
group by bin ;


#switch table
#rename table h_house to h_houseold;
#rename table h_house to h_house;
#drop table h_houseold;
