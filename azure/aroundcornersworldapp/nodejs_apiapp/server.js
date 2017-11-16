/**
 * Copyright 2015 Marcelo Leal. All Rights Reserved.
 * Copyright 2013 Ricard Aspeljung. All Rights Reserved.
 *
 * server.js
 */

var fs = require("fs"),
  mongodb = require("mongodb"),
  restify = module.exports.restify = require("restify");

var DEBUGPREFIX = "DEBUG: ";

var config = {
  "mongodb": {
    "port": 27017,
    "host": "localhost",
    "username": "",
    "password": ""
  },
  "server": {
    "port": 8080,
    "address": "0.0.0.0"
  },
  "dbengine": "mongodb",
  "flavor": "mongodb",
  "debug": true
};

var debug = module.exports.debug = function (str) {
  if (config.debug) {
    console.log(DEBUGPREFIX + str);
  }
};

try {
  config = JSON.parse(fs.readFileSync(process.cwd() + "/config.json"));
} catch (e) {
  debug("No config.json file found. Fall back to default config.");
}

module.exports.config = config;

var server = restify.createServer({
  name: "nodejs_apiapp"
});
server.acceptable = ['application/json'];
server.use(restify.acceptParser(server.acceptable));
server.use(restify.bodyParser());
server.use(restify.fullResponse());
server.use(restify.queryParser());
server.use(restify.jsonp());
module.exports.server = server;

if (config.dbengine == 'docdb') {
   require('./lib/docdb');
   } else if (config.dbengine == 'mongodb') {
   	     require('./lib/mongodb');
          } else {
	         console.log("Unknown DB enginge, aborting...");
		 process.exit(1);
}

server.listen( process.env.PORT || config.server.port, function () {
  console.log("%s listening at %s", server.name, server.url);
});
