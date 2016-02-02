#! /bin/bash

LINE=$1

NAME=$(echo $LINE | csvcut -c 1)
ADDR1=$(echo $LINE | csvcut -c 1)
ADDR2=$(echo $LINE | csvcut -c 2)
ADDR3=$(echo $LINE | csvcut -c 3)
ADDR4=$(echo $LINE | csvcut -c 4)

RESULT=$(curl -s "http://nominatim.openstreetmap.org/search/?q=$(urlencode $NAME $ADDR1 $ADDR2 $ADDR3 $ADDR4)&format=json&polygon_geojson=1")
if [[ "${RESULT}" == "[]" ]] ; then
    RESULT=$(curl -s "http://nominatim.openstreetmap.org/search/?q=$(urlencode $ADDR1 $ADDR2 $ADDR3 $ADDR4)&format=json&polygon_geojson=1")
fi
if [[ "${RESULT}" == "[]" ]] ; then
    RESULT=$(curl -s "http://nominatim.openstreetmap.org/search/?q=$(urlencode $ADDR2 $ADDR3 $ADDR4)&format=json&polygon_geojson=1")
fi
if [[ "${RESULT}" == "[]" ]] ; then
    RESULT=$(curl -s "http://nominatim.openstreetmap.org/search/?q=$(urlencode $ADDR3 $ADDR4)&format=json&polygon_geojson=1")
fi
if [[ "${RESULT}" == "[]" ]] ; then
    RESULT=$(curl -s "http://nominatim.openstreetmap.org/search/?q=$(urlencode $ADDR4)&format=json&polygon_geojson=1")
fi

echo "${NAME},${ADDR1},${ADDR2},${ADDR3},${ADDR4},${RESULT}"
