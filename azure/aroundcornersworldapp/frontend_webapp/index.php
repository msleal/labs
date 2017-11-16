<!DOCTYPE html>
<!-- Copyright(c) - Marcelo Leal -->
<html>
<head>
  <title>AroundCorners | World Application</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <!-- Our CSS -->
  <link rel="stylesheet" href="https://aroundcornersworldapp.blob.core.windows.net/assets/css/style.css" type="text/css" media="screen"/>
  <!-- Google Font -->
  <link rel='stylesheet' href='http://fonts.googleapis.com/css?family=Yanone+Kaffeesatz%3A400%2C300%2C700&#038;ver=1.1.23' type='text/css' media='all' />
  <!-- Javascripts -->
  <script src="https://aroundcornersworldapp.blob.core.windows.net/assets/js/jquery-1.7.2.min.js"></script>
  <script src="https://aroundcornersworldapp.blob.core.windows.net/assets/js/jquery-jvectormap-1.2.2.min.js"></script>
  <script src="https://aroundcornersworldapp.blob.core.windows.net/assets/js/jquery-jvectormap-world-mill-en.js"></script>
</head>
<body>
  <?php 
  //Analytics
  if (getenv('APPSETTING_ANALYTICS')) {
     if (getenv('APPSETTING_ANALYTICS') != "xxx") {
        include_once("analyticstracking.php");
     }
  };
  ?>
  <div>
     <img src="https://aroundcornersworldapp.blob.core.windows.net/assets/img/earth.png"></img>
     <h2>AroundCorners World Application</h2>
     <h3><a href="map.php">City</a> | <a href="time.php">Time</a></h3>
     <p>Copyright(c) 2015 <a href="http://twitter.com/msleal">Marcelo Leal</a></p>
  <div>
</body>
</html>
