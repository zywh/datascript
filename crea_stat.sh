#!/bin/bash


sqlcmd="mysql -u root -p19701029 mls"


#get city New Data
sql="

SELECT count(*) c,municipality,county 
FROM crea group by municipality 
ORDER BY c 
INTO OUTFILE '/tmp/city.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

`$sqlcmd -e "$sql"`

sql="

SELECT count(*) c,type_own1_out
FROM crea group by type_own1_out
ORDER BY c
INTO OUTFILE '/tmp/type.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

`$sqlcmd -e "$sql"`



sql="

SELECT count(*) c,style
FROM crea group by style
ORDER BY c
INTO OUTFILE '/tmp/style.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

`$sqlcmd -e "$sql"`



sql="

SELECT count(*) c,s_r
FROM crea group by s_r
ORDER BY c
INTO OUTFILE '/tmp/s_r.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

`$sqlcmd -e "$sql"`


sql="

SELECT count(*) c,community
FROM crea group by community
ORDER BY c
INTO OUTFILE '/tmp/community.csv'
FIELDS TERMINATED BY '|'
LINES TERMINATED BY '\n';

"

`$sqlcmd -e "$sql"`



