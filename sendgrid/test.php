<?php

// If you are using Composer (recommended)
//require 'vendor/autoload.php';
require __DIR__ . '/vendor/autoload.php';

//use Auth0\SDK\API\Authentication;

$MAPLEAPP_SPA_SECRET = "Wg1qczn2IKXHEfzOCtqFbFCwKhu-kkqiAKlBRx_7VotguYFnKOWZMJEuDVQMXVnG";
$MAPLEAPP_SPA_AUD = ['9fNpEj70wvf86dv5DeXPijTnkLVX5QZi'];
$MAPLEAPP_SPA_VOW_SECRET = "Wg1qczn2";
$MAPLEAPP_SPA_VOW_AUD = ['9fNpEj70'];
$MAPLEAPP_SPA_VOW_LIFETIME = 87200; // 60 days expiration

$token = str_replace('Bearer ', '', 'dfasf');
$secret = 'LWBDkRn0MFncXknYlCFIgkeG0HfadY_TNuskNtF6D1tbHHtdUpONcOXJR7oo3-qB';
$client_id = 'sfyFhgeWtYy5x1W5fOwFg2FEqnHRHae3';
$decoded_token = null;
   echo "decode token\n";
     // $decoded_token = \Auth0\SDK\Auth0JWT::decode($token,$client_id,$secret );
    $decoded_token = \Auth0\SDK\Auth0JWT::encode($token,$client_id,$secret );


//$decoded_token = \Auth0\SDK\Auth0JWT::encode($MAPLEAPP_SPA_VOW_AUD, $MAPLEAPP_SPA_VOW_SECRET, null, null, $MAPLEAPP_SPA_VOW_LIFETIME);

//var_dump($VOWToken);


echo "done\n";

// If you are not using Composer
// require("path/to/sendgrid-php/sendgrid-php.php");

$from = new SendGrid\Email(null, "inf@maplecity.com.cn");
$subject = "Hello World from the SendGrid PHP Library!";
$to = new SendGrid\Email(null, "zhengying@yahoo.com");
$content = new SendGrid\Content("text/plain", "Hello, Email!");
$mail = new SendGrid\Mail($from, $subject, $to, $content);

$apiKey = getenv('SENDGRID_API_KEY');
$sg = new \SendGrid($apiKey);

#$response = $sg->client->mail()->send()->post($mail);
?>
