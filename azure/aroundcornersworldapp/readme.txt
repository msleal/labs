#Cities Database...
#(cd nosqldb_scripts/create_and_load; ./01_create_json.sh)

#Resource Group
az group create --name ACWORLDAPP --location brazilsouth

#ACI MongoDB
az container create --resource-group acworldapp --name mongodb --image mongo --ip-address public --port 27017 --location eastus --output json
export MONGOHOST="`az container show --resource-group acworldapp --name mongodb --output table | grep -w mongodb | awk '{print $5}'`"

(cd nosqldb_scripts/create_and_load; ./02_load_json.sh $MONGOHOST)

#CosmosDB
az cosmosdb create --resource-group acworldapp --name cosmosdbnosql --kind MongoDB --default-consistency-level Eventual
export COSMOSCONNSTR=`az cosmosdb list-connection-strings --resource-group acworldapp --name cosmosdbnosql --output json | grep 'connectionString": "' | awk '{print $2}' | sed 's/"//g'`
export COSMOSHOST=`echo $COSMOSCONNSTR | sed 's/^.*@//' | sed 's/\/.*$//'`
export COSMOSUSER=`echo $COSMOSCONNSTR | sed 's/mongodb:\/\///' | sed 's/:.*$//'`
export COSMOSPASSWD=`echo $COSMOSCONNSTR | awk -F: '{print $3}' | sed 's/^.*://' | sed 's/@.*$//'`
(cd nosqldb_scripts/create_and_load; ./02_load_json.sh $COSMOSHOST $COSMOSUSER $COSMOSPASSWD --ssl)

#Container TODO App accessing Cosmosdb...
docker run -d --env DB="$COSMOSCONNSTR" -p 80:3000 --name todoapp msleal/todoapp
