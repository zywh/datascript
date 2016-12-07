<?php

$homedir="/tmp";
$pichome="/mls/treb/";
$vowresidata = $homedir."resione.txt";
$vowcondodata= $homedir."condoone.txt";

require_once("phrets.php");
$rets_login_url = "http://rets.torontomls.net:6103/rets-treb3pv/server/login";
$rets_username = "V16yzh";
$rets_password = "Ap$3778";

$id='W3660394';



//$TimeBackPull = "-6 days";
$TimeBackPull = "-90 days";

$rets_modtimestamp_field = "Timestamp_sql";
//$previous_start_time = date('Y-m-d', strtotime($TimeBackPull))."T00:00:00";
$previous_start_time = date('Y-m-d', strtotime($TimeBackPull));
$query = "(ml_num={$id})";


echo "$query\n";

// start rets connection
$rets = new phRETS;
//$rets->SetParam("offset_support", true);
$property_classes = array("ResidentialProperty","CondoProperty");
//$property_classes = array("CondoProperty");
$connect = $rets->Connect($rets_login_url, $rets_username, $rets_password);

if ($connect) {
        echo "  + Connected<br>\n";
}
else {
        echo "  + Not connected:<br>\n";
        print_r($rets->Error());
        exit;
}


function downloadpic($type,$id) {
global $rets,$homedir,$pichome;
$photos = $rets->GetObject("Property", "Photo", $id);
$photofolder = $pichome."Photo".$id;
//$photofolder = $homedir.$type."/picture/Photo".$id;

echo count($photos);



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
                                //fputcsv($fh, $fields_order,"|");
                        }


                        // process results
                        while ($record = $rets->FetchRow($search)) {
                                $this_record = array();

                                foreach ($fields_order as $fo) {
                                        $this_record[] = $record[$fo];
					echo $record[$fo]."|";
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

?>