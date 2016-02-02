#! /bin/bash

while read LINE ; do
    ./geocode-single.sh "${LINE}"
done
