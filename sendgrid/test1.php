<?php
 require __DIR__ . '/vendor/autoload.php';

  // Create Router instance
  $router = new \Bramus\Router\Router();

  // Check JWT on /secured routes. This can be any route you like

    // This method will exist if you're using apache
    // If you're not, please go to the extras for a defintion of it.

    // validate the token
    $token = str_replace('Bearer ', '', 'dfasf');
    $secret = 'LWBDkRn0MFncXknYlCFIgkeG0HfadY_TNuskNtF6D1tbHHtdUpONcOXJR7oo3-qB';
    $client_id = 'sfyFhgeWtYy5x1W5fOwFg2FEqnHRHae3';
    $decoded_token = null;
    try {
	echo "decode token\n";
      $decoded_token = \Auth0\SDK\Auth0JWT::decode($token,$client_id,$secret );
      $decoded_token = \Auth0\SDK\Auth0JWT::encode($token,$client_id,$secret );
    } catch(\Auth0\SDK\Exception\CoreException $e) {
      echo "Invalid token";
      exit();
    }

?>
