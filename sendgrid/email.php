
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
$g1 = "g1";
$g1User = "admin";
$g1Password = "19701029";

// Create connection
$conn = new mysqli($servername, $username, $password,'mls');
$g1sql = new mysqli($g1, $g1User, $g1Password,'hdm106787551_db');

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
} 
if ($g1sql->connect_error) {
    die("G1 Connection failed: " . $g1sql->connect_error);
}



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

function match($email,$city){
$row = 1;
if (($handle = fopen($piccount, "r")) !== FALSE) {
    while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
        $house=getHouse($data[0]);
        $to=match($house);
        if ( $to ){
        $subject=emailSubject($house);
        $content=emailBody($house);
        echo $subject;
        }


    }
    fclose($handle);
}

$city=$house['municipality'];
$sql="select email from h_user_data where mailFlag='1' and myCenter=";
$email="zhengying@yahoo.com";
return $email;
	
}

$to="zhengying@yahoo.com";
#$to="dzheng@gmail.com";
#email($to,$subject,$content);

$selectUser="select username,myCenter from h_user_data where mailFlag=1;";
$result = $g1sql->query($selectUser);
if ($result->num_rows > 0) {
    while($row = $result->fetch_assoc()) {
        #var_dump($row);
	$email=$row['username'];
	$cities = $row['myCenter'];
	echo count($cities);
	echo var_dump($cities);
	#match($email,$city);
    }
} 


?>
