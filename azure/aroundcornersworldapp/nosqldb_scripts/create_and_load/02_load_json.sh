#!/bin/bash
#byLeal

# This is a very, very simple script to load JSON files into CosmosDB or MongoDB.
# IMPORTANT: It's assumed that the destination collection is empty.
# Copyright(c) - Marcelo Leal   

## Database hostname...
if [ $# -lt 1 ]; then
   echo "Error: You must provide a mongodb/cosmosdb hostname"
   exit 1
fi

DB="$1";
COLLECTION="cities";
MONGOIMPORT="/usr/local/bin/mongodb-linux-x86_64-ubuntu1604-3.4.10/bin/mongoimport"

#MongoDB (CosmosDB compatible, the only difference is that CosmosDB by default has strict security requirements)...
for x in `echo db/import/*`; do 
    if [ $# -gt 1 ]; then
       #CosmosDB
       if [ $4 == "--ssl" ]; then
          # cat $x | tr -d '\n' | mongoimport -h $DB -u $2 -p $3 -c $COLLECTION --jsonArray --ssl --sslAllowInvalidCertificates --numInsertionWorkers 4 
          $MONGOIMPORT -h $DB -u $2 -p $3 -c $COLLECTION --ssl --sslAllowInvalidCertificates --file $x
       else
          echo"Azure Cosmos DB has strict security requirements and standards. Be sure to enable SSL when you interact with your account."
       fi
    else
       #MongoDB
       # cat $x | tr -d '\n' | mongoimport -h $DB -c $COLLECTION --jsonArray; 
       $MONGOIMPORT -h $DB -c $COLLECTION --file $x --numInsertionWorkers 8
    fi
done

#DocumentDB (Just one windows command, here is splitted in multiple lines for readability)
#.\dt.exe /s:JsonFile /s.Files:c:\users\{your user here}\workspace\db\raw\cities1000.json /t:DocumentDBBulk 
# /t.ConnectionString:"AccountEndpoint=https://{your account here}.documents.azure.com:443/;AccountKey={your key here};Database={your db here}" 
# /t.Collection:{your collection here} /t.CollectionTier:S3

#TODO: Test the above command in Wine. A simple utility like above may work without issues...
