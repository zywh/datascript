<?php


// Payload data you want to send to Android device(s)
// (it will be accessible via intent extras)    
$data = array('message' => 'Hello World!');

// The recipient registration tokens for this notification
// https://developer.android.com/google/gcm/    
$ids = array('abc', 'def');

// Send push notification via Google Cloud Messaging
sendPushNotification($data, $ids);

function sendPushNotification($data, $ids) {
    // Insert real GCM API key from the Google APIs Console
    // https://code.google.com/apis/console/        
    $apiKey = getenv("GCM_APIKEY");

    // Set POST request body
    $post = array(
                    'registration_ids'  => $ids,
                    'data'              => $data,
                 );

    // Set CURL request headers 
    $headers = array( 
                        'Authorization: key=' . $apiKey,
                        'Content-Type: application/json'
                    );

    // Initialize curl handle       
    $ch = curl_init();

    // Set URL to GCM push endpoint     
    curl_setopt($ch, CURLOPT_URL, 'https://gcm-http.googleapis.com/gcm/send');

    // Set request method to POST       
    curl_setopt($ch, CURLOPT_POST, true);

    // Set custom request headers       
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

    // Get the response back as string instead of printing it       
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

    // Set JSON post data
    curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($post));

    // Actually send the request    
    $result = curl_exec($ch);

    // Handle errors
    if (curl_errno($ch)) {
        echo 'GCM error: ' . curl_error($ch);
    }

    // Close curl handle
    curl_close($ch);

    // Debug GCM response       
    echo $result;
}

?>
