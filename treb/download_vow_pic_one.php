<?php

$homedir="/mls/172.30.0.108/";
$pichome="/mls/treb/";
$vowresidata = $homedir."vowresi/data/data.txt";
$vowcondodata= $homedir."vowcondo/data/data.txt";

require_once("phrets.php");
$rets_login_url = "http://rets.torontomls.net:6103/rets-treb3pv/server/login";
$rets_username = "V16yzh";
$rets_password = "Ap$3778";
#$inputfile = $argv[1];
$id='W3686941';
echo $id;




// start rets connection
$rets = new phRETS;
$rets->SetParam("offset_support", true);
$property_classes = array("ResidentialProperty","CondoProperty");
$connect = $rets->Connect($rets_login_url, $rets_username, $rets_password);

if ($connect) {
        echo "  Connected<br>\n";
}
else {
        echo "  + Not connected:<br>\n";
        print_r($rets->Error());
        exit;
}

downloadpic($id);


function downloadpic($id){
global $rets,$homedir,$pichome;

$photos = $rets->GetObject("Property", "Photo", $id);
$photofolder = $pichome."Photo".$id;
//$photofolder = $homedir.$type."/picture/Photo".$id;

$count=count($photos);
echo $id."-Count:".$count."\n";

if (!is_dir($photofolder)) {
       mkdir($photofolder);
}



foreach ($photos as $photo) {
        $listing = $photo['Content-ID'];
        $number = $photo['Object-ID'];

        if ($photo['Success'] == true) {
 		$destination = "/Photo".$id."-".$number.".jpeg";
                file_put_contents($photofolder.$destination, $photo['Data']);
        }
        else {
                echo "({$listing}-{$number}): {$photo['ReplyCode']} = {$photo['ReplyText']}\n";
        }
}

}

echo "Disconnecting\n";
$rets->Disconnect();

?>
