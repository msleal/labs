#!/bin/bash
#byLeal

# This is a very, very simple script to load JSON files into DocumentDB or MongoDB.
# IMPORTANT: It's assumed that the destination collection is empty.
# Copyright(c) - Marcelo Leal   

## VARS
# You should edit the following variables to fit your deployment...
DB="prod";
COLLECTION="cities";

#MongoDB
for x in `echo db/import/*`; do 
    cat $x | tr -d '\n' | mongoimport -d $DB -c $COLLECTION --jsonArray; 
done

#DocumentDB (Just one windows command, here is splitted in multiple lines for readability)
#.\dt.exe /s:JsonFile /s.Files:c:\users\{your user here}\workspace\db\raw\cities1000.json /t:DocumentDBBulk 
# /t.ConnectionString:"AccountEndpoint=https://{your account here}.documents.azure.com:443/;AccountKey={your key here};Database={your db here}" 
# /t.Collection:{your collection here} /t.CollectionTier:S3

#TODO: Test the above command in Wine. A simple utility like above may work without issues...
