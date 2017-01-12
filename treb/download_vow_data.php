<?php

$homedir="/mls/172.30.0.108/";
$pichome="/mls/treb/";
$vowresidata = $homedir."vowresi/data/data.txt";
$vowcondodata= $homedir."vowcondo/data/data.txt";
$piclist="/tmp/treb_pic_count.tmp";

if (file_exists($piclist)) {
	unlink($piclist);
} 

require_once("phrets.php");
$rets_login_url = "http://rets.torontomls.net:6103/rets-treb3pv/server/login";
$rets_username = "V16yzh";
$rets_password = "Ap$3778";

//$TimeBackPull = "-1 years";
$TimeBackPull = "-26 hours";

$rets_modtimestamp_field = "Timestamp_sql";
$previous_start_time = date('Y-m-d', strtotime($TimeBackPull))."T00:00:00";
$query = "({$rets_modtimestamp_field}={$previous_start_time}+)";




// start rets connection
$rets = new phRETS;
$rets->SetParam("offset_support", true);
$property_classes = array("ResidentialProperty","CondoProperty");
echo "Connecting to {$rets_login_url} as {$rets_username}<br>\n";
$connect = $rets->Connect($rets_login_url, $rets_username, $rets_password);

if ($connect) {
        echo "  + Connected<br>\n";
}
else {
        echo "  + Not connected:<br>\n";
        print_r($rets->Error());
        exit;
}


function downloadpic($type,$id,$city) {
global $rets,$homedir,$pichome,$fpic;
$photos = $rets->GetObject("Property", "Photo", $id);
$photofolder = $pichome."Photo".$id;
//$photofolder = $homedir.$type."/picture/Photo".$id;

$count=count($photos);
$s_piclist="$id,$count,$city\n";
echo "fwrite $s_piclist\n";
fwrite($fpic,$s_piclist);



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

#open piclist file
echo "Open file $piclist \n";
$fpic = fopen($piclist, "w+");

foreach ($property_classes as $class) {

        echo "Property:{$class}\n";
	if ( $class == 'ResidentialProperty'){
		$type = 'vowresi';
        	$file_name = $vowresidata;
	}
	if ( $class == 'CondoProperty'){
		$type = 'vowcondo';
        	$file_name = $vowcondodata;
	}

        $fh = fopen($file_name, "w+");

        $maxrows = true;
        $offset = 1;
        $limit = 1000000;

        $fields_order = array();
 while ($maxrows) {

	echo " Resource: Property   Class: {$class}   Query: {$query}\n";
	$search = $rets->SearchQuery("Property", $class, $query, array('Limit' => $limit, 'Offset' => $offset, 'Format' => 'COMPACT-DECODED', 'Count' => 1));

	$count = $rets->TotalRecordsFound();
		
	 if ($rets->NumRows() > 0) {

                        if ($offset == 1) {
                                $fields_order = $rets->SearchGetFields($search);
                        }


                        // process results
                        while ($record = $rets->FetchRow($search)) {
                                $this_record = array();
				$mls = $record["Ml_num"];
				$city = $record["Municipality"];
				echo "$mls $city\n";
				$photofolder = $pichome."Photo".$mls;
				//$photofolder = $homedir.$type."/picture/Photo".$mls;
				if (!is_dir($photofolder)) {
					echo "Download MLS:$mls pictures\n";
     					mkdir($photofolder);
				downloadpic($type,$mls);
  				}

                                foreach ($fields_order as $fo) {
                                        $this_record[] = $record[$fo];
                                }
                                fputcsv($fh, $this_record,"|");
				
                        }
		 $offset = ($offset + $rets->NumRows());


        }
	$maxrows = $rets->IsMaxrowsReached();

        echo "Total found: {$rets->TotalRecordsFound()}, $offset\n";
        $rets->FreeResult($search);
}
        fclose($fh);
        echo "done\n";

}

echo "Disconnecting\n";
$rets->Disconnect();

        fclose($fpic);
?>
