<?php


$rets_login_url = "http://rets.torontomls.net:6103/rets-treb3pv/server/login";
$rets_username = "D15yzh_a";
$rets_password = "Da$3778";

//////////////////////////////

//require_once("phrets.php");
require_once("phrets.php");
//require_once("PHRets_TREB.php");

// start rets connection
$rets = new phRETS;

$property_classes = array("ResidentialProperty","CondoProperty");
echo "+ Connecting to {$rets_login_url} as {$rets_username}<br>\n";
$connect = $rets->Connect($rets_login_url, $rets_username, $rets_password);

if ($connect) {
        echo "  + Connected<br>\n";
}
else {
        echo "  + Not connected:<br>\n";
        print_r($rets->Error());
        exit;
}

$file_name = strtolower("/tmp/idx.ml");
$fh = fopen($file_name, "w+");

foreach ($property_classes as $class) {

        echo "+ Property:{$class}<br>\n";


        $maxrows = true;
        $offset = 1;
        $limit = 1000000;
        $fields_order = array();

        while ($maxrows) {

		$query = "(Status=|A)";

                // run RETS search
                echo "   + Query: {$query}  Limit: {$limit}  Offset: {$offset}<br>\n";
                $search = $rets->SearchQuery("Property", $class, $query, array('Limit' => $limit, 'Offset' => $offset, 'Format' => 'COMPACT-DECODED', 'Count' => 1));
		$rows = $rets->NumRows();
		$count = $rets->TotalRecordsFound();
		echo "$offset $rows $count\n";
		

                if ($rows > 0) {

                        if ($offset == 1) {
                                // print filename headers as first line
                                $fields_order = $rets->SearchGetFields($search);
				print_r($fields_order);
                                //fputcsv($fh, $fields_order);
                        }

                        // process results
                        while ($record = $rets->FetchRow($search)) {
                                $this_record = array();
                                //foreach ($fields_order as $fo) {
                                        $this_record[] = $record['Ml_num'];
                                //}
                                fputcsv($fh, $this_record);
                        }

                        $offset = ($offset + $rets->NumRows());

                }

                $maxrows = $rets->IsMaxrowsReached();
                echo "    + Total found: {$rets->TotalRecordsFound()}<br>\n";

                $rets->FreeResult($search);
        }



}
fclose($fh);

$rets->Disconnect();

?>
