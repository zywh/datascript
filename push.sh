#!/bin/sh
HOST='hyu1076950001.my3w.com'
PASSWD='ftpmaplecity8888'
USER='hyu1076950001'
FILE="test"

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
pass
cd htdocs/test
put $FILE
dir
quit
END_SCRIPT
