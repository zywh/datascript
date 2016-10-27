<?PHP

/* Script Variables */
// Lots of output, saves requests to a local file.
$debugMode = false; 
// Initially, you should set this to something like "-2 years". Once you have all day, change this to "-48 hours" or so to pull incremental data
$TimeBackPull = "-1 years";
//$TimeBackPull = "-26 hours";

/* RETS Variables */
require("PHRets_CREA_d.php");
//require("PHRets_CREA.php");
$RETS = new PHRets();
$RETSURL = "http://data.crea.ca/Login.svc/Login";
$RETSUsername = "aX2L1jM613F56rZadx78KLUS";
$RETSPassword = "RYJwQZsTD18OaqQorwqJ0s1v";
$RETS->Connect($RETSURL, $RETSUsername, $RETSPassword);
$RETS->AddHeader("RETS-Version", "RETS/1.7.2");
$RETS->AddHeader('Accept', '/');
$RETS->SetParam('compression_enabled', true);
$RETS_PhotoSize = "LargePhoto";
$RETS_LimitPerQuery = 100;
if($debugMode /* DEBUG OUTPUT */)
{
	//$RETS->SetParam("catch_last_response", true);
	$RETS->SetParam("debug_file", "/var/web/CREA_Anthony.txt");
	$RETS->SetParam("debug_mode", true);
}


function landsize($line) {
	
	$line = strtolower ($line);
	$line = preg_replace('/\s+/', '', $line);
	
	if (strpos($line, 'sq') !== false){
		$line = str_replace('.', '', $line);
	}
	
	$remove[] = "unit=";
	$remove[] = ",";
	$remove[] = "approx";	
	//$line = str_replace(',', '', $line);
	//$line = str_replace('approx', '', $line);
	$line = str_replace($remove, '', $line);
	$line = str_replace('acre', 'ac', $line);
	$line = str_replace('acres', 'ac', $line);
	$line = str_replace('acs', 'ac', $line);
	$line = str_replace('sqmeters', 'sqm', $line);
	$line = preg_replace('/or*/', '|', $line);
	$line = preg_replace('/\(/', '|', $line);
	$line = preg_replace('/irr/', '|', $line);
	$line = preg_replace('/app/', '|', $line);
	$o = "$line";

	// | 
	if (strpos($line, '|') !== false) { 
		$pipe =explode("|", $line);
		
		if ( strpos($pipe[0], 'ac') !== false ) { // | 0.5 ac|under 1 acre
			$ot = str_replace("ac","",$pipe[0]);
			if ( is_numeric($ot) ) {
			  $o = $ot * 43560;
			}
			
		} 
		
		if ( strpos($pipe[0], 'sqft') !== false ) { // 8051sqft|
			$ot = str_replace("sqft","",$pipe[0]);
			if ( is_numeric($ot) ) {
			  $o = $ot;
			}
			
		} 
		if ( is_numeric($pipe[0] ))  {
			  $o = $pipe[0] * 43560;
		}
	
	}
		
	if (strpos($line, '|') == false && strpos($line, 'ac') !== false ) { //4.65ac
		 
		 $ot = str_replace("ac","",$line);
		 if ( is_numeric($ot) ) {
			  $o = $ot * 43560;
		 }
		
	}
	

	if (strpos($line, 'm2') !== false) {   //857.6m2  
		$ot = str_replace("m2","",$line);
		
		if ( is_numeric($ot) ) {
			  $o = $ot * 10.76;
		 }
	} 
	
	//sqft
	if (strpos($line, 'sqft') !== false) {
		if (strpos($line, '|') !== false) { 
			$pipe =explode("|", $line);
			$ot = $pipe[0];
		}
		
		$ot = str_replace("sqft","",$line);
		if ( is_numeric($ot) ){
			$o = $ot;
		}
		
	} 
	
	//sqm
	if (strpos($line, 'sqm') !== false) {
		if (strpos($line, '|') !== false) { 
			$pipe =explode("|", $line);
			$ot = $pipe[0];
			$ot = str_replace("sqm","",$ot);
		} 
		else {
			$ot = str_replace("sqm","",$line);
		}
		
		if ( is_numeric($ot) ){
			$o = $ot * 10.76;
		}
		
	} 
	
	

	
	// md:
	
	if (strpos($line, 'md:') !== false && strpos($line, 'w:') !== false) {
		$pipe =explode(":", $line);
		$o1 = str_replace("md","",$pipe[1]);
		$o2 = preg_replace('/m.*/',"",$pipe[2]);
		
		if ( is_numeric($o1) && is_numeric($o2)) {  //w:16.3300md:33.5000mshape:rec

			$o = $o1 * $o2 * 10.76;
		}
		
	}
	if (is_numeric($line)) {
		$o = $line; 
	 }
	
	
	// a x b
	
	if (strpos($line, 'x') !== false) { 
		
		$factor = 1;
		$pipe = str_replace("'","",$line); // remove '
		
		
		if ( strpos($pipe, '|') !== false ){
			$pipe = explode("|", $pipe);
			$pipe = $pipe[0];
		}
		
		$pipe = str_replace("ft","",$pipe); // remove ft
		$pipe = str_replace("feet","",$pipe); // remove ft
		if (strpos($pipe, 'm') !== false ){
			$pipe = str_replace("m","",$pipe); // remove m
			$factor = 10.76;
			
		}
		
		$pipe =explode("x", $pipe);
		if ( is_numeric($pipe[0]) && is_numeric($pipe[1]) ) { //50x140
			$o = $pipe[0] * $pipe[1] * $factor;
		}

		
	}
	
	if ( is_numeric($o) ) {
		return $o;
	}
	else {
		return '0';
	}
	
	
}


function size($d){
			
		//12 ft x 20 ft ,2 in 
		// OR 4.70 m x 3.91 m
		// OR 12 ft x
        $rm1_len ="0";
        $rm1_wth ="0";
		
		if (is_string($d) && strpos($d, 'x') !== false) {
			//list($wth,$len) = explode("x", $d);
			$s = explode("x", $d);
			$wth = $s[0];
			$len = $s[1];
			if (strpos($wth, 'ft') !== false) {
					$l = str_replace(",",".",$wth);
					$l = str_replace("ft","",$l);
					$l = str_replace("in","",$l);
					$rm1_wth = preg_replace('/\s+/', '', $l);
			}
			if (strpos($wth, 'm') !== false) {
					$factor = floatval("3.28");
					$l = str_replace("m","",$wth);
					$l = preg_replace('/\s+/', '', $l);
					$rm1_wth = $factor * floatval($l);
			}

			if (strpos($len, 'ft') !== false) {
					$factor = 1;
					$len = str_replace(",",".",$len);
					$len = str_replace("ft","",$len);
					$len = str_replace("in","",$len);
					$rm1_len = preg_replace('/\s+/', '', $len);
			}
			if (strpos($len, 'm') !== false) {
					$factor = floatval("3.28");
					$l = str_replace("m","",$len);
					$l = preg_replace('/\s+/', '', $l);
					$rm1_len = $factor * floatval($l);
			}
			
		}
        $array["wth"] = $rm1_wth;
        $array["len"] = $rm1_len;

        return  $array;

}


function listdefault($listing) {
   $id = $listing["ListingID"];

}


function land($listing){
	$id = $listing["ListingID"];
	//echo "$id is LAND\n";
}
	

function resi($listing,$type)
{
	$ml_num = $listing["ListingID"];
	$id = $listing["@attributes"]["ID"];
	#$lastupdate = $listing["@attributes"]["LastUpdated"];
	#$pix_updt = date('Y-m-d',strtotime($lastupdate));
	if (isset($listing["ListingContractDate"])){

	$lastupdate = $listing["ListingContractDate"];
	$lastupdate = str_replace('/', '-', $lastupdate);
	$pix_updt = date('Y-m-d',strtotime($lastupdate));
	}else {
	 $lastupdate = $listing["@attributes"]["LastUpdated"];
	 $pix_updt = date('Y-m-d',strtotime($lastupdate));

	}

	
	
	if (isset($listing["Address"]["StreetAddress"])) {
		$s = $listing["Address"]["StreetAddress"];
		//Prevent | cause issue as CSV delimitor
		$addr = str_replace("|"," ",$s);
	}
	else{ $addr = ""; }
	
	//Process city with comma - Panorama Hills, Calgary
	if (isset($listing["Address"]["City"])){
		$s = $listing["Address"]["City"];
		$municipality = $s;
		if (strpos($s, ',') !== false) {
			$ss = explode(",",$s);
			//Panorama Hills, Calgary - Get name after comma
			$municipality = trim($ss[1]);
		}		
			
	} else { $municipality =""; }
	
	
	$community = isset($listing["Address"]["CommunityName"])? $listing["Address"]["CommunityName"] : "" ;
	
	//Convert Exposure to single letter
	if (isset($listing["Address"]["StreetDirectionSuffix"])) {
		$s = $listing["Address"]["StreetDirectionSuffix"];
		$comp_pts = "";
		if (strpos($s, 'East') !== false) {
			$fcomp_pts = "E";
		}
		if (strpos($s, 'West') !== false) {
			$comp_pts = "W";
		}
		if (strpos($s, 'North') !== false) {
			$comp_pts = "N";
		}
		if (strpos($s, 'South') !== false) {
			$comp_pts = "S";
		}
	} else { $comp_pts = "";}	
	
	//Generate acres - string and land_area = number
	//It translate it into land_area and acres accordingly

	
	
	if (isset($listing["Land"]["SizeTotalText"]) ) {
		//echo "Start SizeTotalText".$listing["Land"]["SizeTotalText"]."\n";	
		$s = $listing["Land"]["SizeTotalText"];
		 $land_area = landsize($s);
		 $acres =  str_replace("|","-",$s);;
	} else {
			$land_area = "0";
			$acres = "";
	}
	
	/*
	if (isset($listing["Land"]["SizeTotal"]) && $land_area = "0" ) {
		$s = $listing["Land"]["SizeTotal"];
		$land_area = landsize($s);
		$acres = $s;
	} else {
		$land_area = 0;
		$acres = "";
	}*/
	
	//echo "LandSize:".$land_area."LandSizeText:".$acres."\n";
	
	$zip = isset($listing["Address"]["PostalCode"])? $listing["Address"]["PostalCode"] : "" ;
	$county = isset($listing["Address"]["Province"])? $listing["Address"]["Province"] : "" ;
	// [CoolingType] => Central air conditioning
	$a_c = isset($listing["Building"]["CoolingType"])? $listing["Building"]["CoolingType"] : "";
	
	
	//[ConstructedDate] => 2006
	$yr_built = isset($listing["Building"]["ConstructedDate"])? $listing["Building"]["ConstructedDate"]: ""; 
	
	// 1580 sqft or Array NULL
	
	if (isset($listing["Building"]["SizeInterior"])) {
		$s = $listing["Building"]["SizeInterior"];
		$sqft = "";
		if ( is_string($s)){
			$sqft =  $s;
		}
		
	}
	else { $sqft = ""; }
	
	
	//
	$bsmt1_out = isset($listing["Building"]["BasementDevelopment"])? $listing["Building"]["BasementDevelopment"]: "" ;
	$bsmt2_out =  isset($listing["Building"]["BasementType"])? $listing["Building"]["BasementType"] : "";
	$br = isset($listing["Building"]["BedroomsTotal"])? $listing["Building"]["BedroomsTotal"]: "" ;
	$constr1_out = isset($listing["Building"]["ConstructionMaterial"])? $listing["Building"]["ConstructionMaterial"] : "";
	
	//[FireplacePresent] => False
	if (isset($listing["Building"]["FireplacePresent"])) {
		$s = $listing["Building"]["FireplacePresent"];
		$fpl_num = "";
		if (strpos($s, 'True') !== false) {
			$fpl_num = "Y";
		}
		if (strpos($s, 'False') !== false) {
			$fpl_num = "N";
		}
	} else { $fpl_num = "";}
	
	
	
	$gar_spaces = isset($listing["ParkingSpaces"]["Parking"]["Spaces"])? $listing["ParkingSpaces"]["Parking"]["Spaces"] : "";
	//$gar_type = isset($listing["ParkingSpaces"]["Parking"]["Name"])? $listing["ParkingSpaces"]["Parking"]["Name"] : "";
	$fuel = isset($listing["Building"]["HeatingFuel"])? $listing["Building"]["HeatingFuel"] : "";
	$heating = isset($listing["Building"]["HeatingType"])? $listing["Building"]["HeatingType"] : "";
	
	//Kit
	$num_kit = 0;
	//ROOMS start
	$level1 = isset($listing["Building"]["Rooms"]["Room"]["0"]["Level"])? $listing["Building"]["Rooms"]["Room"]["0"]["Level"] : "";
	//$rm1_out = isset($listing["Building"]["Rooms"]["Room"]["0"]["Type"])? $listing["Building"]["Rooms"]["Room"]["0"]["Type"] : "";
	if (isset($listing["Building"]["Rooms"]["Room"]["0"]["Type"])) {
		$rm1_out = $listing["Building"]["Rooms"]["Room"]["0"]["Type"];
		if ( strpos($rm1_out, 'Kit') !== false ){
		++$num_kit;
		}
	} else { $rm1_out = "";}
 
	
	$level2 = isset($listing["Building"]["Rooms"]["Room"]["1"]["Level"])? $listing["Building"]["Rooms"]["Room"]["1"]["Level"] : "";
	
	if (isset($listing["Building"]["Rooms"]["Room"]["1"]["Type"])) {
		$rm2_out = $listing["Building"]["Rooms"]["Room"]["1"]["Type"];
		if ( strpos($rm2_out, 'Kit') !== false ){
		++$num_kit;
		}
	} else { $rm2_out = "";}
	$level3 = isset($listing["Building"]["Rooms"]["Room"]["2"]["Level"])? $listing["Building"]["Rooms"]["Room"]["2"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["2"]["Type"])) {
		$rm3_out = $listing["Building"]["Rooms"]["Room"]["2"]["Type"];
		if ( strpos($rm3_out, 'Kit') !== false ){
		++$num_kit;
		}
	} else { $rm3_out = "";}
	
	$level4 = isset($listing["Building"]["Rooms"]["Room"]["3"]["Level"])? $listing["Building"]["Rooms"]["Room"]["3"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["3"]["Type"])) {
		$rm4_out = $listing["Building"]["Rooms"]["Room"]["3"]["Type"];
		if ( strpos($rm4_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm4_out = "";}
	
	$level5 = isset($listing["Building"]["Rooms"]["Room"]["4"]["Level"])? $listing["Building"]["Rooms"]["Room"]["4"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["4"]["Type"])) {
		$rm5_out = $listing["Building"]["Rooms"]["Room"]["4"]["Type"];
		if ( strpos($rm5_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm5_out = "";}
	
	$level6 = isset($listing["Building"]["Rooms"]["Room"]["5"]["Level"])? $listing["Building"]["Rooms"]["Room"]["5"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["5"]["Type"])) {
		$rm6_out = $listing["Building"]["Rooms"]["Room"]["5"]["Type"];
		if ( strpos($rm6_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm6_out = "";}
	
	$level7 = isset($listing["Building"]["Rooms"]["Room"]["6"]["Level"])? $listing["Building"]["Rooms"]["Room"]["6"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["6"]["Type"])) {
		$rm7_out = $listing["Building"]["Rooms"]["Room"]["6"]["Type"];
		if ( strpos($rm7_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm7_out = "";}
	
	$level8 = isset($listing["Building"]["Rooms"]["Room"]["7"]["Level"])? $listing["Building"]["Rooms"]["Room"]["7"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["7"]["Type"])) {
		$rm8_out = $listing["Building"]["Rooms"]["Room"]["7"]["Type"];
		if ( strpos($rm8_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm8_out = "";}
	
	$level9 = isset($listing["Building"]["Rooms"]["Room"]["8"]["Level"])? $listing["Building"]["Rooms"]["Room"]["8"]["Level"] : "";
	
	if (isset($listing["Building"]["Rooms"]["Room"]["8"]["Type"])) {
		$rm9_out = $listing["Building"]["Rooms"]["Room"]["8"]["Type"];
		if ( strpos($rm9_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm9_out = "";}
	

	$level10 = isset($listing["Building"]["Rooms"]["Room"]["9"]["Level"])? $listing["Building"]["Rooms"]["Room"]["9"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["9"]["Type"])) {
		$rm10_out = $listing["Building"]["Rooms"]["Room"]["9"]["Type"];
		if ( strpos($rm10_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm10_out = "";}
	
	$level11 = isset($listing["Building"]["Rooms"]["Room"]["10"]["Level"])? $listing["Building"]["Rooms"]["Room"]["10"]["Level"] : "";

	if (isset($listing["Building"]["Rooms"]["Room"]["10"]["Type"])) {
		$rm11_out = $listing["Building"]["Rooms"]["Room"]["10"]["Type"];
		if ( strpos($rm11_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm11_out = "";}
	
	$level12 = isset($listing["Building"]["Rooms"]["Room"]["11"]["Level"])? $listing["Building"]["Rooms"]["Room"]["11"]["Level"] : "";
	
	if (isset($listing["Building"]["Rooms"]["Room"]["11"]["Type"])) {
		$rm12_out = $listing["Building"]["Rooms"]["Room"]["11"]["Type"];
		if ( strpos($rm12_out, 'Kit') !== false ){
		++$num_kit;

		}
	} else { $rm12_out = "";}
	
	//ROOMS Repeat 12 times. Write a function to handle it
	
	if (isset($listing["Building"]["Rooms"]["Room"][0]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][0]["Dimension"];
		//print_r($d);
		$rm1_wth = size($d)["wth"];
        $rm1_len = size($d)["len"];

	}
	else { 
		$rm1_len = "0";
		$rm1_wth = "0";
	}
	
	
	if (isset($listing["Building"]["Rooms"]["Room"][1]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][1]["Dimension"];
		$rm2_wth = size($d)["wth"];
        $rm2_len = size($d)["len"];

	}
	else { 
		$rm2_len = "0";
		$rm2_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][2]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][2]["Dimension"];
		$rm3_wth = size($d)["wth"];
        $rm3_len = size($d)["len"];

	}
	else { 
		$rm3_len = "0";
		$rm3_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][3]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][3]["Dimension"];
		$rm4_wth = size($d)["wth"];
        $rm4_len = size($d)["len"];

	}
	else { 
		$rm4_len = "0";
		$rm4_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][4]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][4]["Dimension"];
		$rm5_wth = size($d)["wth"];
        $rm5_len = size($d)["len"];

	}
	else { 
		$rm5_len = "0";
		$rm5_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][5]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][5]["Dimension"];
		$rm6_wth = size($d)["wth"];
        $rm6_len = size($d)["len"];

	}
	else { 
		$rm6_len = "0";
		$rm6_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][6]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][6]["Dimension"];
		$rm7_wth = size($d)["wth"];
        $rm7_len = size($d)["len"];

	}
	else { 
		$rm7_len = "0";
		$rm7_wth = "0";
	}	
	if (isset($listing["Building"]["Rooms"]["Room"][7]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][7]["Dimension"];
		$rm8_wth = size($d)["wth"];
        $rm8_len = size($d)["len"];

	}
	else { 
		$rm8_len = "0";
		$rm8_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][8]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][8]["Dimension"];
		$rm9_wth = size($d)["wth"];
        $rm9_len = size($d)["len"];

	}
	else { 
		$rm9_len = "0";
		$rm9_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][9]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][9]["Dimension"];
		$rm10_wth = size($d)["wth"];
        $rm10_len = size($d)["len"];

	}
	else { 
		$rm10_len = "0";
		$rm10_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][10]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][10]["Dimension"];
		$rm11_wth = size($d)["wth"];
        $rm11_len = size($d)["len"];

	}
	else { 
		$rm11_len = "0";
		$rm11_wth = "0";
	}
	if (isset($listing["Building"]["Rooms"]["Room"][11]["Dimension"])) {
		$d = $listing["Building"]["Rooms"]["Room"][11]["Dimension"];
		$rm12_wth = size($d)["wth"];
        $rm12_len = size($d)["len"];

	}
	else { 
		$rm12_len = "0";
		$rm12_wth = "0";
	}	
	

	//Levels end
	
	$lp_dol = isset($listing["Price"])? $listing["Price"] : "" ;
	$prop_feat1_out = isset($listing["AmmenitiesNearBy"])? $listing["AmmenitiesNearBy"] : "" ;
	$prop_feat2_out = isset($listing["Land"]["Amenities"])? $listing["Land"]["Amenities"] : "" ;
	$prop_feat3_out = isset($listing["Features"])? $listing["Features"] : "" ;
	$prop_feat4_out = isset($listing["Land"]["LandscapeFeatures"])? $listing["Land"]["LandscapeFeatures"] : "" ;
	
	if (isset($listing["PublicRemarks"])) {
		$s = $listing["PublicRemarks"] ;
		//Prevent | cause issue as CSV delimitor
		$ad_text = str_replace("|","",$s);
	}
	else{ $ad_text=""; }
	
	
	if (isset($listing["TransactionType"])) {
		
		$saletag = $listing["TransactionType"] ;
		$s_r= "";
		if (strpos($saletag, 'sale') !== false) {
			$s_r = "Sale";
		}
		if (strpos($saletag, 'rent') !== false) {
			$s_r = "Lease";
			$lp_dol = isset($listing["Lease"])? $listing["Lease"] : "" ;
		}		
		if (strpos($saletag, 'lease') !== false) {
			$s_r = "Lease";
			$lp_dol = isset($listing["Lease"])? $listing["Lease"] : "";
		}
		
	} 
	else {$s_r ="";}
	
	// [Appliances] => Microwave, Dishwasher, Central Vacuum, Water softener

	if (isset($listing["Building"]["Appliances"])) {
		
		$s = $listing["Building"]["Appliances"];
		$central_vac = "";
		if (strpos($s, 'Vacuum') !== false) {
			$central_vac = "Y";
		}
	
		
	} 
	else { $central_vac = "";}
	
	$style = isset($listing["Building"]["StoriesTotal"])? $listing["Building"]["StoriesTotal"] : "";
	$bath_tot = isset($listing["Building"]["BathroomTotal"])? $listing["Building"]["BathroomTotal"] : "" ;
	
	//[ConstructionStyleAttachment] => Detached
	if (isset($listing["Building"]["ConstructionStyleAttachment"])){
		$type_own1_out = $listing["Building"]["ConstructionStyleAttachment"];
	}
	elseif (isset($listing["Building"]["Type"])){
		$type_own1_out = $listing["Building"]["Type"];
	} 
	else {$type_own1_out ="";}
	
	if ($type == "Vacant Land"){
		$type_own1_out = "Vacant Land";
	}
	
	$pool = isset($listing["PoolType"])? $listing["PoolType"] : "" ;
	
	if (isset($listing["AlternateURL"]["VideoLink"])) {
		$s = $listing["AlternateURL"]["VideoLink"];
		$tour_url = str_replace("|","",$s);
	}
	else { $tour_url = "";}
	
	
	
	echo "$id|$ml_num|$addr|$a_c|$yr_built|$sqft|$bsmt1_out|$bsmt2_out|$br|$constr1_out|$fpl_num|$gar_spaces|$fuel|$heating|$level1|$rm1_out|$rm1_len|$rm1_wth|$level2|$rm2_out|$rm2_len|$rm2_wth|$level3|$rm3_out|$rm3_len|$rm3_wth|$level4|$rm4_out|$rm4_len|$rm4_wth|$level5|$rm5_out|$rm5_len|$rm5_wth|$level6|$rm6_out|$rm6_len|$rm6_wth|$level7|$rm7_out|$rm7_len|$rm7_wth|$level8|$rm8_out|$rm8_len|$rm8_wth|$level9|$rm9_out|$rm9_len|$rm9_wth|$level10|$rm10_out|$rm10_len|$rm10_wth|$level11|$rm11_out|$rm11_len|$rm11_wth|$level12|$rm12_out|$rm12_len|$rm12_wth|$lp_dol|$municipality|$zip|$county|$prop_feat1_out|$prop_feat2_out|$prop_feat3_out|$prop_feat4_out|$ad_text|$s_r|$style|$bath_tot|$type_own1_out|$community|$comp_pts|$land_area|$acres|$pix_updt|$pool|$central_vac|$tour_url|$num_kit\n";
	
}

function downloadPhotos($listingID,$ml_num)
{
	global $RETS, $RETS_PhotoSize, $debugMode;
	
	//if(!$downloadPhotos)
	//{
	//	if($debugMode) error_log("Not Downloading Photos");
	//	return;
	//}

	$photos = $RETS->GetObject("Property", $RETS_PhotoSize, $listingID, '*');
	
	if(!is_array($photos))
	{
		if($debugMode) error_log("Cannot Locate Photos");
		return;
	}

	if(count($photos) > 0)
	{
		$count = 0;
		foreach($photos as $photo)
		{
			if(
				(!isset($photo['Content-ID']) || !isset($photo['Object-ID']))
				||
				(is_null($photo['Content-ID']) || is_null($photo['Object-ID']))
				||
				($photo['Content-ID'] == 'null' || $photo['Object-ID'] == 'null')
			)
			{
				continue;
			}
			
			$listing = $photo['Content-ID'];
			$number = $photo['Object-ID'];
			$photofolder = "/mls/crea/Photo".$ml_num;
			if (!is_dir($photofolder)) {
				// dir doesn't exist, make it
				mkdir($photofolder);
			}

			$destination = "Photo".$ml_num."-".$number.".jpg";
			$photoData = $photo['Data'];
			
			/* @TODO SAVE THIS PHOTO TO YOUR PHOTOS FOLDER
			 * Easiest option:
			 * 	file_put_contents($destination, $photoData);
			 * 	http://php.net/function.file-put-contents
			 */
			file_put_contents($photofolder . "/" . $destination, $photoData); 
			$count++;
		}
		
		if($debugMode)
			error_log("Downloaded ".$count." Images For '".$listingID."'");
	}
	elseif($debugMode)
		error_log("No Images For '".$listingID."'");
	
	// For good measure.
	if(isset($photos)) $photos = null;
	if(isset($photo)) $photo = null;
}

/* NOTES
 * With CREA, You have to ask the RETS server for a list of IDs.
 * Once you have these IDs, you can query for 100 listings at a time
 * Example Procedure:
 * 1. Get IDs (500 Returned)
 * 2. Get Listing Data (1-100)
 * 3. Get Listing Data (101-200)
 * 4. (etc)
 * 5. (etc)
 * 6. Get Listing Data (401-500)
 *
 * Each time you get Listing Data, you want to save this data and then download it's images...
 */
 
error_log("-----GETTING ALL ID's-----");
$DBML = "(LastUpdated=" . date('Y-m-d', strtotime($TimeBackPull)) . ")";
$params = array("Limit" => 1, "Format" => "STANDARD-XML", "Count" => 1);
$results = $RETS->SearchQuery("Property", "Property", $DBML, $params);
$totalAvailable = $results["Count"];
error_log("-----".$totalAvailable." Found-----");
if(empty($totalAvailable) || $totalAvailable == 0)
	error_log(print_r($RETS->GetLastServerResponse(), true));	
for($i = 0; $i < ceil($totalAvailable / $RETS_LimitPerQuery); $i++)
{
	$startOffset = $i*$RETS_LimitPerQuery;
	
	error_log("-----Get IDs For ".$startOffset." to ".($startOffset + $RETS_LimitPerQuery).". Mem: ".round(memory_get_usage()/(1024*1024), 1)."MB-----");
	$params = array("Limit" => $RETS_LimitPerQuery, "Format" => "STANDARD-XML", "Count" => 1, "Offset" => $startOffset);
	$results = $RETS->SearchQuery("Property", "Property", $DBML, $params);			
	foreach($results["Properties"] as $listing)
	{
		$ID = $listing["@attributes"]["ID"];
		//if($debugMode) error_log($listingID);
	
		/* @TODO Handle $listing array. Save to Database? */
		//David START
		$property_type = $listing["PropertyType"];
		switch ($property_type) {
			case "Single Family":
			 resi($listing,"Single Family");
			 $ml_num = $listing["ListingID"];
			 //downloadPhotos($ID,$ml_num);
		 	 break;	
			case "Vacant Land":
			//echo "Start Vacant Land Listing";
			 resi($listing,"Vacant Land");
			  break;
			default:
			 listdefault($listing); 

		}
		

		//David End	
		
		/* @TODO Uncomment this line to begin saving images. Refer to function at top of file */
		
		
	}
}

$RETS->Disconnect();

/* This script, by default, will output something like this:

Connecting to RETS as '[YOUR RETS USERNAME]'...
-----GETTING ALL ID's-----
-----81069 Found-----
-----Get IDs For 0 to 100. Mem: 0.7MB-----
-----Get IDs For 100 to 200. Mem: 3.7MB-----
-----Get IDs For 200 to 300. Mem: 4.4MB-----
-----Get IDs For 300 to 400. Mem: 4.9MB-----
-----Get IDs For 400 to 500. Mem: 3.4MB-----
*/

?>
