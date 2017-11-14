#!/bin/bash
#byLeal

#+----------------------------------------------------------------------+
#|                            -> README <-                              |
#|   This Script uses the public and free of charge database dump from: |
#| GeoNames.org. Take a look at the Terms and Conditions to use these   |
#| data here (official site): http://www.geonames.org/export/.          |
#|   As of Nov/2015 the use is free (even commercial), and the licence  |
#| is "cc-by licence (You should give credit to GeoNames when using     |
#| data or web services with a link or another reference to GeoNames.   |
#|                                       Copyright(c) - Marcelo Leal    |
#+----------------------------------------------------------------------+

# The following variables you could adapt, but a few comments:
# - I have tested/used just the "cities1000.zip" dump file.
# - So, don't know if the structure of the other files are the same. But
# you should be able to just change the FILEURL URL and test it.

## VARS
FILEURL="http://download.geonames.org/export/dump/cities1000.zip";
FILEZIP=$(basename $FILEURL);
FILEDUMP=$(basename $FILEZIP .zip);
RAWDIR="db/raw";
IMPDIR="db/import";

## Validate we have the utilies we need...
for x in unzip wget; do
    which $x >/dev/null
    if [ $? -ne 0 ]; then
       echo "PRE-REQ: You need to have the utility $x installed.";
       exit 1;
    fi
done

# You should not need to edit anything bellow, but I can be wrong...

# Building our home...
for x in "$RAWDIR" "$IMPDIR"; do
    mkdir -p $x;
    if [ $? -ne 0 ]; then
       echo "ERROR: Creating directory $x.";
       exit 1;
    fi
done

## Let's do it...
echo "INFO: Downloading Cities Dump File from Geonames.org..."
(cd "$RAWDIR"; wget -q "$FILEURL");
if [ $? -ne 0 ]; then
   echo "ERROR Downloading Cities Dump File from Geonames.org."
   exit 1
fi

(cd "$RAWDIR"; unzip -q "$FILEZIP");
if [ $? -ne 0 ]; then
   echo "ERROR Extracting Cities Dump File."
   exit 1
fi

# Remove the first (ID) column...
(cd "$RAWDIR"; awk '{print substr($0, index($0, $2))}' "$FILEDUMP".txt > "$FILEDUMP");
if [ $? -ne 0 ]; then
   echo "ERROR Removing Cities Dump File first Column."
   exit 1
fi

# Now we create our JSON file (normalized to lowercase) to use as a simple database or import it in a DB (e.g.: Azure Documentdb OR MongoDB)
echo "INFO: Creating Cities JSON File...";
(cd "$RAWDIR"; awk 'BEGIN {FS="\t"}; {printf ("{\"name\":\"%s\", \"lat\":\"%s\", \"lng\":\"%s\"}\n", tolower($1),tolower($4),tolower($5))}' "$FILEDUMP" > "$FILEDUMP".json);
if [ $? -ne 0 ]; then
   echo "ERROR Creating Cities JSON File."
   exit 1
fi

# We do split the json file to facilitate the import (MongoDB import utility had some issues with big files)...
split -l 50000 "$RAWDIR"/"$FILEDUMP".json $IMPDIR/"$FILEDUMP"_
if [ $? -ne 0 ]; then
   echo "ERROR Spliting Cities JSON File."
   exit 1
fi

# Got here? Good!
echo "INFO: Cities JSON File Created Successfully."
exit 0
