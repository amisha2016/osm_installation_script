<<"COMMENT"

apt-get -y install libboost-all-dev subversion git-core tar unzip wget bzip2 build-essential autoconf libtool libxml2-dev libgeos-dev libgeos++-dev libpq-dev libbz2-dev libproj-dev munin-node munin libprotobuf-c0-dev protobuf-c-compiler libfreetype6-dev libpng12-dev libtiff5-dev libicu-dev libgdal-dev libcairo-dev libcairomm-1.0-dev apache2 apache2-dev libagg-dev liblua5.2-dev ttf-unifont lua5.1 liblua5.1-dev libgeotiff-epsg node-carto

apt-get -y install make cmake g++ libboost-dev libboost-system-dev \
  libboost-filesystem-dev libexpat1-dev zlib1g-dev \
  libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev lua5.2 \
  liblua5.2-dev

sudo apt-get -y install libmapnik-dev libmapnik3.0 mapnik-utils mapnik-vector-tile python-mapnik python3-mapnik


sudo apt-get -y install cmake
sudo apt-get -y install python-pip
pip install mapnik
apt-get install postgresql postgresql-contrib postgis postgresql-9.4-postgis-2.1



n="amisha"


#sudo -u postgres createuser $n

#sudo -u postgres createdb -E UTF8 -O $n gis
#sudo -u postgres psql --command  '\c gis'
#dbname="gis"
sudo -u postgres psql << EOF
\c gis
CREATE EXTENSION postgis;
ALTER TABLE geometry_columns OWNER TO amisha;
ALTER TABLE spatial_ref_sys OWNER TO amisha;
\q
EOF



#mkdir ~/src
#cd ~/src
#git clone https://github.com/openstreetmap/osm2pgsql.git

#cd ~/src/osm2pgsql
#mkdir build && cd build

cmake ~/src/osm2pgsql
cd build
make
sudo make install




cd ~/src
#git clone https://github.com/openstreetmap/mod_tile.git
cd mod_tile
 #chmod 777 -R mod_tile
#./autogen.sh


./configure
make

sudo make install
sudo make install-mod_tile
sudo ldconfig

COMMENT



#sudo mkdir -p /usr/local/share/maps/style
sudo chown amisha /usr/local/share/maps/style
cd /usr/local/share/maps/style
#wget https://github.com/mapbox/osm-bright/archive/master.zip
#wget http://data.openstreetmapdata.com/simplified-land-polygons-complete-3857.zip
#wget http://data.openstreetmapdata.com/land-polygons-split-3857.zip
#mkdir ne_10m_populated_places_simple
#cd ne_10m_populated_places_simple
#wget http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_populated_places_simple.zip
#unzip ne_10m_populated_places_simple.zip
#rm ne_10m_populated_places_simple.zip
#cd ..

#unzip '*.zip'
#mkdir osm-bright-master/shp
#cp land-polygons-split-3857 osm-bright-master/shp/
#cp simplified-land-polygons-complete-3857 osm-bright-master/shp/
#cp ne_10m_populated_places_simple osm-bright-master/shp/

cd osm-bright-master/shp/land-polygons-split-3857
shapeindex land_polygons.shp
cd ../simplified-land-polygons-complete-3857/
shapeindex simplified_land_polygons.shp
cd ../..

exit


