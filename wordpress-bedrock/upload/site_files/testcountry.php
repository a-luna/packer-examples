<?php
  require_once '/sites/example.com/bedrock/vendor/autoload.php';
  use GeoIp2\Database\Reader;

  // This creates the Reader object, which should be reused across
  // lookups.
  $reader = new Reader('/etc/nginx/geoip2/GeoLite2-Country.mmdb');
  $record = $reader->country('8.8.8.8');

  echo "<pre>";
  print_r($record);