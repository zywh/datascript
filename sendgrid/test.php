<?php
// If you are using Composer (recommended)
require 'vendor/autoload.php';
$piccount="/tmp/treb_pic_count.tmp";
$apiKey = getenv('SENDGRID_API_KEY');
$from = new SendGrid\Email('maplecity', "info@maplecity.com.cn");
$servername = "localhost";
$username = getenv('SQL_LOCAL_USER');
$password = getenv('SQL_LOCAL_PASS');
$g1 =  getenv('SQL_G1');
$g1User =  getenv('SQL_G1_USER');
$g1Password =  getenv('SQL_G1_PASS');

#require_once('vendor/autoload.php');
use \Firebase\JWT\JWT;
$key = getenv("JWT_VOW_KEY");
$key = JWT::urlsafeB64Decode($key);
$token = array(
    "aud" => "9fNpEj70",
);

$jwt = JWT::encode($token, $key);

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


function median($numbers=array())
{
	if (!is_array($numbers))
		$numbers = func_get_args();
	
	rsort($numbers);
	$mid = (count($numbers) / 2);
	return ($mid % 2 != 0) ? $numbers{$mid-1} : (($numbers{$mid-1}) + $numbers{$mid}) / 2;
}


function getHouse($mls,$c){
	
	global $conn;
	$sql = "SELECT ml_num,s_r,municipality,lp_dol,num_kit,br,addr,bath_tot from h_housetmp where  ml_num='".$mls."' AND ".$c;
	//echo "$sql\n";
	$result = $conn->query($sql);
	if ($result->num_rows > 0) {
		
		while($row = $result->fetch_assoc()) {
			
			$house=$row;
			
		}
		
	}
	
	
	else {
		
		$house=[];
	}
	
	return $house;
}


function getHouses($c) {
       global $conn;
        $sql = "SELECT ml_num,s_r,municipality,lp_dol,num_kit,br,addr,bath_tot from h_housetmp where dom=0 and ".$c;
	//echo "$sql\n";
        $result = $conn->query($sql);
        if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
                        $house[]=$row;

                }

        }


        else {

                $house=[];
        }

        return $house;

}



function emailBody($house){
	global $jwt;
	$urlp="http://i.citym.ca/#/housedetail/";
	$imagep="http://creac.citym.ca/treb/Photo".$house['ml_num']."/Photo".$house['ml_num']."-1.jpeg";
	$body = '<h2 style="text-align: center;">枫之都新房源通知</h2>';
	$body .= "<table style='height: 170px;' width='457'><tbody><tr><td>";
	$body .= "<img src=".$imagep."  width='160' height='160' /></td><td><table style='height: 135px;' width='212'><tbody><tr>";
	$body .= "<td>MLS: ".$house['ml_num']." &nbsp;&nbsp;".$house['br']."房".$house['bath_tot']."卫</td></tr><tr><td>";
	$body .= "<p>地址：".$house['addr'].",".$house['municipality']."</p></td></tr><tr>";
	$body .= "<td>价格：".$house['lp_dol']."</td>";
	$body .= "	</tr>	</tbody>	</table>	</td>	</tr>	</tbody>	</table>	<h2><a href=".$urlp.$house['ml_num']."/".$jwt.">查看详情&nbsp;	</a></h2>	<p>&nbsp;	</p>";
	$body .= '<div id="yiv9195951082">IMPORTANT NOTICE: This message is intended only for the use of the individual or entity to which it is addressed, and may contain information that is privileged, confidential and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by email and delete the message. Thank you.</div>	';
		
	//$	body="<a href=".$urlp.$house['ml_num'].">Price: ".$house['lp_dol']." <br> Bedroom ".$house['br']."<br> Bath:".$house['bath_tot']." <br> Address:".$house['addr']."</a>";
	
	return $body;
	
}




function emailSubject($house){
	
	$s= $house['municipality'].":".$house['addr']." ".$house['br']."房".$house['bath_tot']."卫 - 价格:".$house['lp_dol'];
	return $s;
	
}



function email($to,$subject,$house){
	
global $apiKey,$from,$jwt;
echo "send email\n";
var_dump($house);
$urlp="http://i.citym.ca/#/housedetail/";
$ulink="http://www.google.com";
$hurl=$urlp.$house['ml_num']."/".$jwt;
$imagep="http://creac.citym.ca/treb/Photo".$house['ml_num']."/Photo".$house['ml_num']."-1.jpeg";
$to = new SendGrid\Email(null, $to);
$body = new SendGrid\Content("text/html", " ");
#$body = new SendGrid\Content("text/html","test" );
$mail = new SendGrid\Mail($from, $subject, $to, $body);
$mail->personalization[0]->addSubstitution("-mls-", $house['ml_num']);
$mail->personalization[0]->addSubstitution("-price-", $house['lp_dol']);
$mail->personalization[0]->addSubstitution("-addr-", $house['addr']);
$mail->personalization[0]->addSubstitution("-hurl-", $hurl);
$mail->personalization[0]->addSubstitution("-ulink-", $ulink);
$mail->personalization[0]->addSubstitution("-iurl-", $imagep);
$mail->setTemplateId("8ad5d103-6d70-4ca5-a404-b77f12e7fd8d");

#$mail = new SendGrid\Mail($from,"test", $to, $body);
$sg = new \SendGrid($apiKey);
try {
    $response = $sg->client->mail()->send()->post($mail);
} catch (Exception $e) {
    echo 'Caught exception: ',  $e->getMessage(), "\n";
}

echo $response->statusCode();
echo $response->headers();
echo $response->body();

}




function match($email,$condition){
	
	global $piccount;
	$row = 1;
        //open latest picture donwload
	if (($handle = fopen($piccount, "r")) !== FALSE) {
		while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
			if ( (int)$data[3] <2){  //if dom is less than 2 days
				//echo "$data[0]\n";
				$house=getHouse($data[0],$condition);
				if ($house){
					$subject=emailSubject($house);
					$content=emailBody($house);
					//echo "send email $subject to $email $content\n";
					#send email if match
					#email($email,$subject,$content);
					email($email,$subject,$house);
				}
				
				
			}
		}
		
	}
	
	fclose($handle);
	
}

function matchCond($fav,$recent){
global $conn;
$c = [];
$mlList=array_merge(explode(",",$fav),explode(",",$recent));
$inList = implode("','",$mlList);
#$sql = "SELECT avg(lp_dol) avgp,avg(br) avgb,count(*) count,municipality from h_housetmp where s_r='Sale' and ml_num in ('".$inList."') group by municipality order by count desc limit 2";
$sql = "SELECT  GROUP_CONCAT(lp_dol) plist, GROUP_CONCAT(br) brlist,count(*) count,municipality from h_housetmp where s_r='Sale' and ml_num in ('".$inList."') group by municipality order by count desc limit 2";
        $result = $conn->query($sql);
        if ($result->num_rows > 0) {
                while($row = $result->fetch_assoc()) {
		$plist = explode(",",$row['plist']);
		$blist = explode(",",$row['brlist']);
		
		$medianp= median($plist);
		$pmax = $medianp*1.3;
		$pmin = $medianp*0.7; 
		$c[] = "(municipality='".$row['municipality']."' and lp_dol < $pmax and lp_dol > $pmin)";


                }

        }

$s = implode(" OR ",$c);
return "($s)";


}

$selectUser="select username,houseFav,recentView,myCenter from h_user_data where mailFlag=1;";
#$selectUser="select username,houseFav,recentView,myCenter from h_user_data ";
$result = $g1sql->query($selectUser);

if ($result->num_rows > 0) {
	while($row = $result->fetch_assoc()) {
		$email=$row['username'];
		$cities = $row['myCenter'];
		$condition=matchCond($row['houseFav'],$row['recentView']);
		echo "$email,$condition\n";
		//$houses=getHouses($condition);
		//var_dump($houses);
		match($email,$condition);
				
			
		}
		
		
}
	
	
	





?>
