SHELL := /bin/bash

all: install primary-schools.csv


primary-schools.xls:
	wget -O primary-schools.xls https://www.education.ie/en/Publications/Statistics/Data-on-Individual-Schools/Primary-and-Special-Schools-List-2014-2015.xls

primary-schools.csv: primary-schools.xls
	xls2csv primary-schools.xls > primary-schools.csv

primary-schools-addresses.csv: primary-schools.csv
	cat primary-schools.csv | sed 1d | csvcut -c 4,5,6,7,8 > primary-schools-addresses.csv

primary-schools-addresses-geocoded.csv: primary-schools-addresses.csv
	cat primary-schools-addresses.csv | sed 1d | ./geocode.sh > primary-schools-addresses-geocoded.csv

primary-schools-areas.shp: primary-schools-addresses-geocoded.csv
	-rm primary-schools-areas.*
	python make-geocoded-address-shapefile.py primary-schools-addresses-geocoded.csv primary-schools-areas.geojson
	ogr2ogr primary-schools-areas.shp primary-schools-areas.geojson


current-schools.geojson:
	curl 'https://overpass-api.de/api/interpreter' --silent --compressed -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --data 'data=%2F*%0AThis+has+been+generated+by+the+overpass-turbo+wizard.%0AThe+original+search+was%3A%0A%E2%80%9Camenity%3Dschool%E2%80%9D%0A*%2F%0A%5Bout%3Ajson%5D%5Btimeout%3A25%5D%3B%0A%2F%2F+gather+results%0A(%0A++%2F%2F+query+part+for%3A+%E2%80%9Camenity%3Dschool%E2%80%9D%0A++node%5B%22amenity%22%3D%22school%22%5D(51.2206474303833%2C-10.96435546875%2C55.51619215717891%2C-5.3173828125)%3B%0A++way%5B%22amenity%22%3D%22school%22%5D(51.2206474303833%2C-10.96435546875%2C55.51619215717891%2C-5.3173828125)%3B%0A++relation%5B%22amenity%22%3D%22school%22%5D(51.2206474303833%2C-10.96435546875%2C55.51619215717891%2C-5.3173828125)%3B%0A)%3B%0A%2F%2F+print+results%0Aout+body%3B%0A%3E%3B%0Aout+skel+qt%3B' | ./node_modules/.bin/osmtogeojson > current-schools.geojson

current-schools-points.shp: current-schools.geojson
	-rm current-schools-points.*
	ogr2ogr -nlt POINT -skipfailures current-schools-points.shp current-schools.geojson OGRGeoJSON

current-schools-lines.shp: current-schools.geojson
	-rm current-schools-lines.*
	ogr2ogr -nlt LINESTRING -skipfailures current-schools-lines.shp current-schools.geojson OGRGeoJSON

current-schools-polygons.shp: current-schools.geojson
	-rm current-schools-polygons.*
	ogr2ogr -nlt POLYGON -skipfailures current-schools-polygons.shp current-schools.geojson OGRGeoJSON

current-shapefiles: current-schools-points.shp current-schools-lines.shp current-schools-polygons.shp


Second-Level-Schools-List-2014-2015.xlsx:
	wget https://www.education.ie/en/Publications/Statistics/Data-on-Individual-Schools/Second-Level-Schools-List-2014-2015.xlsx

install:
	sudo apt-get install catdoc gridsite-clients gdal-bin
	pip install --user csvkit requests
	npm install osmtogeojson
