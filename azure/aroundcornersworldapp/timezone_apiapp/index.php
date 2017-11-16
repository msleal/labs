 <?php
   //byLeal

   //TIMEZONE API v1.0
   //October 2015
   //Parameters: Timezone identifier (?tz=America/Sao_Paulo)
   //Returns: Local time (e.g.: 22:59 on Thursday 5th November 2015)
   //Copyright(c) - Marcelo Leal

   //Initializing...
   $HOSTCONF = include('config.php');
   if (getenv('APPSETTING_TWITTERTAG')) { $TTAG = getenv('APPSETTING_TWITTERTAG'); } else { $TTAG = $HOSTCONF['ttag']; }
   date_default_timezone_set('America/Sao_Paulo');
   $time = new DateTime('');

   //Get the timezone request...
   $requested_timezone = isset($_GET['tz']) ? $_GET['tz'] : 'America/Sao_Paulo';
   $req_tz_notag = str_replace("$TTAG", '', $requested_timezone);
   $req_tz_notag = trim("$req_tz_notag");
   $new_timezone = new DateTimeZone("$req_tz_notag");

   //Calculates the time and print it...
   $time->setTimezone($new_timezone);
   header('Content-Type: application/json');
   $obj = array('time' => $time->format('H:i \o\n l jS F Y'));
   echo json_encode($obj);
 ?>
