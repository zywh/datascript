<?PHP

#$handle = fopen("/home/ubuntu/size1", "r");
$handle = fopen("/home/ubuntu/size2", "r");
if ($handle) {
    while (($line = fgets($handle)) !== false) {
     $s = landsize($line);
	 echo "$s\n";
    }

    fclose($handle);
} else {
    // error opening the file.
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
	//echo "$o\n";
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
		/*
		if ( strpos($pipe[0], 'ft') !== false && strpos($pipe[1], 'ft') !== false ) { // 70.51ftx106.63ft
			$ot1 = str_replace("ft","",$pipe[0]);
			$ot2 = str_replace("ft","",$pipe[1]);
			if ( is_numeric($ot1) && is_numeric($ot2) ) {
			  $o = $ot1 * $ot2 * $factor;
			}
			
		}
		*/		
		
	}
	
	if ( is_numeric($o) ) {
		return $line."FOUND:".$o;
	}
	else {
		return $line."NOMATCH";
	}
	
	
}


function size($d){

	$rm1_len ="0";
	$rm1_wth ="0";
	list($wth,$len) = explode("x", $d);
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
	$array["wth"] = $rm1_wth;
	$array["len"] = $rm1_len;

	return  $array;

}

if (isset($d)) {
	$rm1_wth = size($d)["wth"];
	$rm1_len = size($d)["len"];
}
else {
$rm1_wth ="0";
$rm1_len ="0";

}
echo "$rm1_wth $rm1_len\n";
?>
