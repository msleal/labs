/**
 * Copyright 2015 Marcelo Leal. All Rights Reserved.
 *
 * docdb.js
 */

var DocumentDBClient = require('documentdb').DocumentClient, 
  BSON = require("mongodb").BSONPure,
  server = module.parent.exports.server,
  restify = module.parent.exports.restify,
  debug = module.parent.exports.debug,
  config = module.parent.exports.config,
  database = process.env.APPSETTING_DOCDB_DATABASE || config.docdb.database,
  collection = process.env.APPSETTING_DOCDB_COLLECTION || config.docdb.collection,
  host = process.env.CUSTOMCONNSTR_DOCDB_ENDPOINT || config.docdb.endpoint,
  masterKey = process.env.CUSTOMCONNSTR_DOCDB_AUTHKEY || config.docdb.authKey,
  dbLink, 
  collLink,
  util = require("./util").util;

debug("docdb.js is loaded");

// Establish a new instance of the DocumentDBClient...
var client = new DocumentDBClient( host, { masterKey: masterKey });

/**
 * Query
 */
function handleGet(req, res, next) {
  debug("GET-request recieved");
  debug(JSON.stringify(req.headers));
  debug(req.query.query);
  var city = JSON.parse(req.query.query);

  var query;
  query = req.query.query ? util.parseJSON(req.query.query, next, restify) : {};

  dbLink = 'dbs/' + database;
  collLink = dbLink + '/colls/' + collection;
  queryStr = "SELECT * FROM cities f WHERE f.name = \'" + city.name + "\'";

  var querySpec = {query: queryStr};
  debug(querySpec.query);
  client.queryDocuments(collLink, querySpec).toArray(function (err, docs) {
  	if (err) {
 		console.log(err);
       	} else {
       		if (req.params.id) {
       			if (docs.length > 0) {
       				debug(JSON.stringify(docs));
       				res.json(docs, {'content-type': 'application/json; charset=utf-8'});
       			} else {
       				res.json(404);
       			}
       		} else {
       			debug(JSON.stringify(docs));
       			res.json(docs, {'content-type': 'application/json; charset=utf-8'});
       		}
       	}
  });
}

server.get('/:db/:collection/:id?', handleGet);
server.get('/:db/:collection', handleGet);
