<<"COMMENT"
OSM Configuration Script
COMMENT
 sed -i 's|"file": "http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip",|"file": "/usr/local/share/maps/style/osm-bright-master/shp/simplified-land-polygons-complete-3857/simplified_land_polygons.shp",\n"type": "shape",|' /usr/local/share/maps/style/osm-bright-master/osm-bright/osm-bright.osm2pgsql.mml

sed -i 's|"file": "http://data.openstreetmapdata.com/land-polygons-split-3857.zip"|"file": "/usr/local/share/maps/style/osm-bright-master/shp/land-polygons-split-3857/land_polygons.shp"|' /usr/local/share/maps/style/osm-bright-master/osm-bright/osm-bright.osm2pgsql.mml

sed -i 's|"file": "http://mapbox-geodata.s3.amazonaws.com/natural-earth-1.4.0/cultural/10m-populated-places-simple.zip"|"file": "/usr/local/share/maps/style/osm-bright-master/shp/ne_10m_populated_places_simple/ne_10m_populated_places_simple.shp",\n"type": "shape"|' /usr/local/share/maps/style/osm-bright-master/osm-bright/osm-bright.osm2pgsql.mml

sed -i '/"name": "ne_places",/,/"srs-name": "autodetect"/{s|"name": "ne_places",|"name": "ne_places",\n"srs": "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"|p;d}' /usr/local/share/maps/style/osm-bright-master/osm-bright/osm-bright.osm2pgsql.mml

cd /usr/local/share/maps/style/osm-bright-master
cp configure.py.sample configure.py

sed -i 's|~/Documents/Mapbox/project|/usr/local/share/maps/style|' /usr/local/share/maps/style/osm-bright-master/configure.py

sed -i 's|"osm"|"gis"|' /usr/local/share/maps/style/osm-bright-master/configure.py

cd /usr/local/share/maps/style/osm-bright-master
./make.py


cd ../OSMBright/
sudo chmod 777 OSMBright.xml
carto project.mml > OSMBright.xml
cd /usr/local/etc/

cat <<EOF >renderd.conf
[renderd]
socketname=/var/run/renderd/renderd.sock
num_threads=4
tile_dir=/var/lib/mod_tile
stats_file=/var/run/renderd/renderd.stats

[mapnik]
plugins_dir=/usr/local/lib/mapnik/input

font_dir=/usr/share/fonts/truetype/lohit-punjabi
font_dir_recurse=1

[default]
URI=/osm_tiles/
TILEDIR=/var/lib/mod_tile
XML=/usr/local/share/maps/style/OSMBright/OSMBright.xml
HOST=localhost 
TILESIZE=256
MAXZOOM=20
CORS=*
EOF




mkdir /var/run/renderd
 chown amisha /var/run/renderd
 mkdir /var/lib/mod_tile
 chown amisha /var/lib/mod_tile


cd /etc/apache2/conf-available/
cat <<EOF >mod_tile.conf
LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so
EOF



cd  /etc/apache2/sites-available/

sed -i 's|ServerAdmin webmaster@localhost|ServerAdmin webmaster@localhost\nLoadTileConfigFile /usr/local/etc/renderd.conf\nModTileRenderdSocketName /var/run/renderd/renderd.sock\n# Timeout before giving up for a tile to be rendered\nModTileRequestTimeout 0\n# Timeout before giving up for a tile to be rendered that is otherwise missing\nModTileMissingRequestTimeout 30|' 000-default.conf



sudo a2enconf mod_tile
sudo service apache2 reload

cd /etc/postgresql/9.4/main/


 sed -i 's|shared_buffers = .*|shared_buffers = 128MB|' postgresql.conf 
sed -i 's|maintenance_work_mem =.*|maintenance_work_mem =256MB|' postgresql.conf 
sed -i 's|checkpoint_segments =.*|checkpoint_segments =20|' postgresql.conf 
sed -i 's|autovacuum =.*|autovacuum = off|' postgresql.conf 

sed -i 's|#kernel.domainname = example.com|#kernel.domainname = example.com\n# Increase kernel shared memory segments - needed for large databases\nkernel.shmmax=268435456|' /etc/sysctl.conf


sudo mkdir /usr/local/share/maps/planet
sudo chown amisha /usr/local/share/maps/planet
cd /usr/local/share/maps/planet 
