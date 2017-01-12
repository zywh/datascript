#!/bin/sh


function email {
# $1 = email
# $2 = subject
# $3 =  body

php -f /home/ubuntu/sendgrid/email.php "$2" "$1" "$3"

}


function gethouse {
# $1 = ml_num

}

#get user list

#
