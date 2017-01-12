
<?php
// If you are using Composer (recommended)
require 'vendor/autoload.php';

// If you are not using Composer
// require("path/to/sendgrid-php/sendgrid-php.php");

$sum="Price: 44444 <br>
Bedroom:3<br>
Bath:4";
$subject=$argv[1];
$to =$argv[2];

$from = new SendGrid\Email('maplecity', "info@maplecity.com.cn");
$to = new SendGrid\Email(null, $to);
$content = new SendGrid\Content("text/html", $sum);
$mail = new SendGrid\Mail($from, $subject, $to, $content);

$apiKey = getenv('SENDGRID_API_KEY');
$sg = new \SendGrid($apiKey);

$response = $sg->client->mail()->send()->post($mail);
echo $response->statusCode();
echo $response->headers();
echo $response->body();

?>
