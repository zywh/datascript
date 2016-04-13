<?PHP

/* Script Variables */
// Lots of output, saves requests to a local file.
$debugMode = false; 
// Initially, you should set this to something like "-2 years". Once you have all day, change this to "-48 hours" or so to pull incremental data
//$TimeBackPull = "-2 years";

/* RETS Variables */
require("PHRets_CREA_d.php");
//require("PHRets_CREA.php");
$RETS = new PHRets();
$RETSURL = "http://data.crea.ca/Login.svc/Login";
$RETSUsername = "aX2L1jM613F56rZadx78KLUS";
$RETSPassword = "RYJwQZsTD18OaqQorwqJ0s1v";
//$RETSUsername = "F7YLu03oxwo8MqGFHpnwssEj";
//$RETSPassword = "SA8GiCRdFqiDqmt78GGWCiSh";

$RETS->Connect($RETSURL, $RETSUsername, $RETSPassword);
$RETS->AddHeader("RETS-Version", "RETS/1.7.2");
$RETS->AddHeader('Accept', '/');
$RETS->SetParam('compression_enabled', true);


$searchurl="http://data.crea.ca/Search.svc/Search";

$search_arguments = array();
$search_arguments['SearchType'] = "Property";
$search_arguments['Class'] = "Property";
$search_arguments['QueryType'] = "DMQL2";
$search_arguments['Format'] = "STANDARD-XML";
$search_arguments['Query'] = "(ID=*)";  //return active listing
$search_arguments['Limit'] = "1";
$search_arguments['Count'] = "1";
 

//$results = $RETS->SearchQuery("Property", "Property", $DBML, $params);

$result = $RETS->RETSRequest($searchurl, $search_arguments);


list($headers, $body) = $result;
$body = $RETS->fix_encoding($body);
$body = utf8_encode($body);
//print_r($body);
$xml = simplexml_load_string($body, "SimpleXMLElement", 0, "urn:CREA.Search.Property", false);
$properties = array();
foreach($xml->children() as $k => $v)
{
	if($k === "RETS-RESPONSE")
	{
		foreach($xml->{'RETS-RESPONSE'}->children() as $k => $v)
			if($k === "PropertyDetails" || $k === "Property")
			$properties []= json_decode(json_encode((array)$v),1);

	}

}

//print_r($properties);

foreach( $properties as $listing)
{
	$ID = $listing["@attributes"]["ID"];
	echo "$ID\n";
	
}


$RETS->Disconnect();


?>
