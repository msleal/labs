<!DOCTYPE html>
<!-- Copyright(c) - Marcelo Leal -->
<html>
<head>
  <title>AroundCorners | World Application</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <!-- Our CSS -->
  <link rel="stylesheet" href="https://aroundcornersworldapp.blob.core.windows.net/assets/css/time.css" type="text/css" media="screen"/>
  <!-- Google Font -->
  <link rel='stylesheet' href='http://fonts.googleapis.com/css?family=Yanone+Kaffeesatz%3A400%2C300%2C700&#038;ver=1.1.23' type='text/css' media='all' />
  <!-- Javascripts -->
  <script src="https://aroundcornersworldapp.blob.core.windows.net/assets/js/jquery-1.7.2.min.js"></script>
  <script src="https://aroundcornersworldapp.blob.core.windows.net/assets/js/jquery-jvectormap-1.2.2.min.js"></script>
  <script src="https://aroundcornersworldapp.blob.core.windows.net/assets/js/jquery-jvectormap-world-mill-en.js"></script>
</head>
<body>
  <!-- Get TZ and Coordinates -->
  <?php
     //Analytics...
     if (getenv('APPSETTING_ANALYTICS')) {
        if (getenv('APPSETTING_ANALYTICS') != "xxx") {
           include_once("analyticstracking.php");
        }
     };

     //FUNCTIONS
     function before ($this, $inthat) {
          return substr($inthat, 0, strpos($inthat, $this));
     };

     //VARS
     $HOSTCONF = include('config.php');
     if (getenv('APPSETTING_TZHOST')) { $TZHOST = getenv('APPSETTING_TZHOST'); } else { $TZHOST = $HOSTCONF['tzhost']; }
     if (getenv('APPSETTING_TZDFLT')) { $TZ = getenv('APPSETTING_TZDFLT'); } else { $TZ = $HOSTCONF['tzdflt']; }

     // Get or Post TZ...
     if (isset($_GET['tz'])) {
        if ($_GET['tz'] != "" ) {
           $TZ = htmlspecialchars($_GET['tz']);
        }
     };
     if (isset($_POST['tz'])) {
        if ($_POST['tz'] != "" ) {
           $TZ = htmlspecialchars($_POST['tz']);
        }
     };

     $TZURL = "http://" . "$TZHOST" . "/index.php?tz="; 
     $json = file_get_contents("$TZURL" . "$TZ");
     $obj = json_decode($json);
     $time = $obj->{'time'};
     $hour = before(':',"$time");
   ?>

   <?php if (($hour > 18) || ($hour < 06)): ?>
         <div id="earthnight">
   <?php else: ?>
         <div id="earthday">
   <?php endif ?>
              <p>Now is <font color="red"><?php echo("$time");?></font> at <?php echo(ucwords("$TZ"));?> | <a href="index.php">HOME</a> | <a href="map.php">CITIES</a> | Copyright(c) 2015<a href="http://twitter.com/msleal"> Marcelo Leal</a></p>
             <form id="highlight" method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>">
                   City Name: <input type="text" name="tz" value="">
                              <input type="submit" name="submit" value="Submit">
             </form>
         </div>
</body>
</html>
