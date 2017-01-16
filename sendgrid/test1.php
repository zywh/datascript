<?php

require_once('vendor/autoload.php');
use \Firebase\JWT\JWT;
#use \Auth0\SDK\JWT;
$key = "Wg1qczn2";
$key = JWT::urlsafeB64Decode($key);
$token = array(
    "aud" => "9fNpEj70",
);

/**
 * IMPORTANT:
 * You must specify supported algorithms for your application. See
 * https://tools.ietf.org/html/draft-ietf-jose-json-web-algorithms-40
 * for a list of spec-compliant algorithms.
 */
$jwt = JWT::encode($token, $key);
print_r($jwt);
#$jwt="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE0ODQ1NzQ0NDIsImp0aSI6IjliZGQ5MTYyZGJmODhjOWU2MWViMzI2OWNkNDkxMzc5IiwiZXhwIjoxNDg0NjYxNjQyLCJhdWQiOlsiOWZOcEVqNzAiXX0.ZyeGE4rE4DHpgZkj9A53VLiXycNSuEWfOkaN9w0YU9o";
$decoded = JWT::decode($jwt, $key, array('HS256'));

#print_r($decoded);

?>
