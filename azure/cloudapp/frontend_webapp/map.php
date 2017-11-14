<!DOCTYPE html>
<!-- Copyright(c) - Marcelo Leal -->
<html>
<head>
  <title>AroundCorners | World Application</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
  <!-- Our CSS -->
  <link rel="stylesheet" href="https://aroundcornersworldapp.blob.core.windows.net/assets/css/map.css" type="text/css" media="screen"/>
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
     // You just need to inform the MAP ApiApp CTHOST and CTDFLT...
     $HOSTCONF = include('config.php');
     if (getenv('APPSETTING_CTHOST')) { $CTHOST = getenv('APPSETTING_CTHOST'); } else { $CTHOST = $HOSTCONF['cthost']; }
     if (getenv('APPSETTING_CTDFLT')) { $CT = strtolower(getenv('APPSETTING_CTDFLT')); } else { $CT = strtolower(rawurlencode($HOSTCONF['ctdflt'])); }

     // Get or Post Coordinates...
     if (isset($_GET['ct'])) { 
        if ($_GET['ct'] != "" ) {
           $CT = strtolower(rawurlencode($_GET['ct']));
        }
     };
     if (isset($_POST['ct'])) { 
        if ($_POST['ct'] != "" ) {
           $CT = strtolower(rawurlencode($_POST['ct']));
        }
     };

     $OPTS = array('http' => array('method'  => 'GET', 'header'  => "user-agent: AC/1.0.0\r\n" . "Accept: */*\r\n" . "Content-Type: application/json\r\n", 'content' => $body, 'timeout' => 60));
     $CONTEXT  = stream_context_create($OPTS);
     $CTQ = '%7B%22name%22%3A%20%22' . "$CT" . '%22%7D&limit=1'; 
     $CTURL = "https://" . "$CTHOST" . "/prod/cities?query=";
     $json = file_get_contents("$CTURL" . "$CTQ", false, $CONTEXT);
     $obj = json_decode($json, true);

     // We will pick just the first city match...
     foreach ($obj as $k=>$v){
     	      $name = $v['name'];
     	      $lat = $v['lat'];
              $lng = $v['lng'];
              break;
     }
     // Just a little formating for presentation...
     $words = explode(" ", $name);
     $c = 0; 
     foreach ($words as $w) { $c++; }
     if ($c < 3) {
     	$name_capital = ucwords($name);
     } else {
     	$exceptions = 'The|And|Do|Dos|Da|Das|De|Des|E|As|A|By|Or|In|To|Of';
        $name_capital = preg_replace('/\\b(\\w)/e', 'strtoupper("$1")', strtolower(trim($name)));
        $name_capital = preg_replace("/(?<=\\W)($exceptions)(?=\\W)/e", 'strtolower("$1")', $name_capital);
     }
  ?>
  <div>
     <!-- Now display the map and infos... -->
     <h2><font color="red"><?php echo("$name_capital");?></font> is at Latitude: <font color="red"><?php echo("$lat");?></font> and Longitude: <font color="red"><?php echo("$lng");?></font></h2>
  </div>
  <div id="world-map" style="width: 1280px; height: 570px"></div>
  <script>
     $(function(){
       $('#world-map').vectorMap({
         map: 'world_mill_en',
         zoomButtons : false,
         normalizeFunction: 'polynomial',
         hoverOpacity: 0.9,
         hoverColor: false,
         backgroundColor: 'transparent',
         regionStyle: {
           initial: {
             fill: 'rgba(0, 0, 0, 1)',
             "fill-opacity": 1,
             stroke: 'none',
             "stroke-width": 0,
             "stroke-opacity": 1
           },
           hover: {
             fill: 'rgba(192, 25, 32, 1)',
             "fill-opacity": 1.0,
             cursor: 'pointer'
           },
           selected: {
             fill: 'red'
           },
           selectedHover: {}
         },
         markerStyle: {
           initial: {
             fill: 'yellow',
	     selected: 'r10',
             stroke: '#111'
           }
         },
         markers: [
           {latLng: [<?php echo("$lat") ?>, <?php echo("$lng"); ?>], name: '<?php echo("$name");?>'}
         ]
       });
     });
  </script>
  <div>
	     <br/>
             <form method="post" action="<?php echo $_SERVER["PHP_SELF"];?>" accept-charset="UTF-8">
                   City Name: <input type="text" name="ct" value="">
                              <input type="submit" name="submit" value="Submit">
             </form>
     <p><strong>| <a href="index.php">HOME</a> | <a href="time.php">TIME</a> | AroundCorners</strong> World Application is using Cities Data from GeoNames.org | Copyright(c) 2015 <a href="http://twitter.com/msleal">Marcelo Leal</a><p/>
  </div>
</body>
</html>
