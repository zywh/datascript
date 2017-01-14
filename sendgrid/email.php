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
	$sql = "SELECT ml_num,s_r,municipality,lp_dol,num_kit,br,addr,bath_tot from h_housetmp where s_r='Sale' and ml_num='".$mls."'";
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




function emailBody($house){
	$urlp="http://i.citym.ca/#/housedetail/";
	$imagep="http://creac.citym.ca/trebtn/Photo".$house['ml_num']."/Photo".$house['ml_num']."-1.jpeg";
	$body = '<h2 style="text-align: center;">枫之都新房源通知</h2>';
	$body .= "<table style='height: 170px;' width='457'><tbody><tr><td>";
	$body .= "<img src=".$imagep."  width='160' height='160' /></td><td><table style='height: 135px;' width='212'><tbody><tr>";
	$body .= "<td>MLS: ".$house['ml_num']." &nbsp;&nbsp;".$house['br']."房".$house['bath_tot']."卫</td></tr><tr><td>";
	$body .= "<p>地址：".$house['addr'].",".$house['municipality']."</p></td></tr><tr>";
	$body .= "<td>价格：".$house['lp_dol']."</td>";
	$body .= "	</tr>	</tbody>	</table>	</td>	</tr>	</tbody>	</table>	<h2><a href=".$urlp.$house['ml_num'].">查看详情&nbsp;	</a></h2>	<p>&nbsp;	</p>";
	$body .= '<div id="yiv9195951082">IMPORTANT NOTICE: This message is intended only for the use of the individual or entity to which it is addressed, and may contain information that is privileged, confidential and exempt from disclosure under applicable law. If the reader of this message is not the intended recipient, you are hereby notified that any dissemination, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender immediately by email and delete the message. Thank you.</div>	';
		
	//$	body="<a href=".$urlp.$house['ml_num'].">Price: ".$house['lp_dol']." <br> Bedroom ".$house['br']."<br> Bath:".$house['bath_tot']." <br> Address:".$house['addr']."</a>";
	
	return $body;
	
}




function emailSubject($house){
	
	
	
	$s= $house['municipality'].":".$house['addr']." ".$house['br']."房".$house['bath_tot']."卫 - 价格:".$house['lp_dol'];
	
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
	
	global $piccount;
	$row = 1;
	if (($handle = fopen($piccount, "r")) !== FALSE) {
		while (($data = fgetcsv($handle, 1000, ",")) !== FALSE) {
			if ($data[2] == $city && (int)$data[3] <2){
				echo "$data[0]\n";
				$house=getHouse($data[0]);
				if ($house){
					$subject=emailSubject($house);
					$content=emailBody($house);
					echo "send email $subject to $email $content\n";
					#send email if match
					email($email,$subject,$content);
				}
				
				
			}
		}
		
	}
	
	fclose($handle);
	
}

$selectUser="select username,myCenter from h_user_data where mailFlag=1;";
$result = $g1sql->query($selectUser);

if ($result->num_rows > 0) {
	while($row = $result->fetch_assoc()) {
		$email=$row['username'];
		$cities = $row['myCenter'];
		if(count($cities)) {
			
			#var_dump($cities);
			$center=json_decode($cities);
			foreach( $center as $c){
				
				if ($c->name){
					echo "$c->name\n";
					match($email,$c->name);
				}
				
				
			}
			
			
		}
		
		
	}
	
	
	
}





?>