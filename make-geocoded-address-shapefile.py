import sys, csv
import json


outputfilename = sys.argv[2]

with open(sys.argv[1]) as fp:
    reader = csv.reader(fp)
    rows = list(reader)

features = []

for row in rows:
    try:
        name, addr1, addr2, addr3, addr4, minlat, maxlat, minlon, maxlon = row
        minlat = float(minlat)
        maxlat = float(maxlat)
        minlon = float(minlon)
        maxlon = float(maxlon)
        features.append({
            'type': 'Feature',
            'geometry': {
                'type': 'Polygon',
                'coordinates':  [[
                    [minlon, maxlat], [maxlon, maxlat],
                    [maxlon, minlat], [minlon, minlat],
                    [minlon, maxlat],
                ]],
            },
            'properties': {
                'name': name,
                'addr1': addr1, 'addr2': addr2, 'addr3': addr3, 'addr4': addr4,
                'full_name': "{}, {}, {}, {}, {}".format(name, addr1, addr2, addr3, addr4),
            },
        })
    except:
        pass

geojson = { 'type': 'FeatureCollection', 'features': features }

with open(outputfilename, 'w') as fp:
    json.dump(geojson, fp)




