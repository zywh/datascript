
<?php
// If you are using Composer (recommended)
require 'vendor/autoload.php';
#$piccount="/tmp/treb_pic_count.tmp"
$piccount="/tmp/test.tmp";

$from = new SendGrid\Email('maplecity', "info@maplecity.com.cn");
$apiKey="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";
$servername = "localhost";
$username = "root";
$password = "19701029";

// Create connection
$conn = new mysqli($servername, $username, $password,'mls');

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
echo "Connected to MYSQL\n";

function getHouse($mls){
global $conn;
$sql = "SELECT ml_num,s_r,municipality,lp_dol,num_kit,br,addr,bath_tot from h_housetmp where ml_num='".$mls."'";
$result = $conn->query($sql);
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
	$house=$row;
    }
} else {
  $house=[];

}
	return $house;

}
// If you are not using Composer
// require("path/to/sendgrid-php/sendgrid-php.php");

function emailBody($house){

	$body="Price: ".$house['lp_dol']." <br> Bedroom:".$house['br']."<br> Bath:".$house['bath_tot'];
	return $body;
}

function emailSubject($house){
	$s= "MLS:".$house['ml_num']." - ".$house['br']."Beds".$house['bath_tot']."Washrooms - Price:".$house['lp_dol'];
	return $s;
}


function email($to,$subject,$content){
global $apiKey,$from;
echo "send email\n";
$to = new SendGrid\Email(null, $to);
$body = new SendGrid\Content("text/html", $content);
#$body = new SendGrid\Content("text/html","test" );
$mail = new SendGrid\Mail($from, $subject, $to, $body);
#$mail = new SendGrid\Mail($from,"test", $to, $body);
$sg = new \SendGrid($apiKey);
$response = $sg->client->mail()->send()->post($mail);

}

$to="zhengying@yahoo.com";
#$to="dzheng@gmail.com";
$house=getHouse("W3683872");
$subject=emailSubject($house);
$content=emailBody($house);
#email($to,$subject,$content);

$row = 1;
if (($handle = fopen($piccount, "r")) !== FALSE) {
    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $num = count($data);
        echo "$num fields in line $row\n";
        $row++;
	var_dump($data);
    }
    fclose($handle);
}

?>
