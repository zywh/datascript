#!/bin/bash

curl -A "Mozilla/4.0 (compatible; MSIE 5.01; Windows NT 5.0)" https://reservations.ontarioparks.com -o /tmp/camp.txt
#disabledate=`grep txtDepCalendarDisabledEndDate /tmp/camp.txt |sed 's/.*2016/2016/'|sed 's/.);//' `
#disabledate=`grep txtDepCalendarDisabledStartDate /tmp/camp.txt |sed 's/.*2016/2016/'|sed 's/.);//' `
disabledate=`grep txtArrivalCalendarDisabledEndDate /tmp/camp.txt |grep SetValue |sed 's/.*2016/2016/'|sed 's/.);//' `

#get last date
lastdate=`tail -1 /tmp/camp.log |cut -d" " -f2`
echo $disabledate $lastdate
if [ "$disabledate" = "$lastdate" ]
then
	echo "Same....."
else
	echo "Warning......"
#send email 

echo "Camping disabled data is changed to $disabledate" | mailx -v -r "zhengying@yahoo.com" -s "camping date change from david" -S smtp="smtp.mail.yahoo.com" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="zhengying@yahoo.com" -S smtp-auth-password="Zywh1234" -S ssl-verify=ignore zhengying@yahoo.com
fi

echo "`date +%m%d%H%M` $disabledate" >>/tmp/camp.log
