<?php
   $json = file_get_contents("timezoneswaggerdefinition.json");
   $obj = json_decode($json);
   header('Content-Type: application/json');
   echo json_encode($obj);
?>
