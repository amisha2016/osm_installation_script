#!/bin/bash
source ./install.conf
<<"COMMENT"
OSM Installation Script
COMMENT

apt -y install libboost-all-dev subversion git-core tar unzip wget bzip2 build-essential autoconf libtool libxml2-dev libgeos-dev libgeos++-dev libpq-dev libbz2-dev libproj-dev munin-node munin libprotobuf-c0-dev protobuf-c-compiler libfreetype6-dev libpng12-dev libtiff5-dev libicu-dev libgdal-dev libcairo-dev libcairomm-1.0-dev apache2 apache2-dev libagg-dev liblua5.2-dev ttf-unifont lua5.1 liblua5.1-dev libgeotiff-epsg node-carto

apt -y install make cmake g++ libboost-dev libboost-system-dev \
  libboost-filesystem-dev libexpat1-dev zlib1g-dev \
  libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev lua5.2 \
  liblua5.2-dev

apt -y install libmapnik-dev libmapnik3.0 mapnik-utils mapnik-vector-tile python-mapnik python3-mapnik


apt -y install cmake
apt -y install python-pip
pip install mapnik
apt -y install postgresql postgresql-contrib postgis postgresql-9.4-postgis-2.1
apt -y install npm nodejs-legacy
npm install -g carto

sudo -u postgres createuser $postgres_user
sudo -u postgres createdb -E UTF8 -O $postgres_user $dbname
sudo -u postgres psql -d $dbname -v user_name=$postgres_user<< EOF
CREATE EXTENSION postgis;
ALTER TABLE geometry_columns OWNER TO :user_name;
ALTER TABLE spatial_ref_sys OWNER TO :user_name;
\q
EOF

<<"COMMENT"
useradd -m $postgres_user
echo "$postgres_user:$postgres_user"|chpasswd
COMMENT

mkdir ~/src
cd ~/src
git clone https://github.com/openstreetmap/osm2pgsql.git

cd ~/src/osm2pgsql
mkdir build && cd build

cmake ~/src/osm2pgsql
cd build
make
 make install
cd ~/src
git clone https://github.com/openstreetmap/mod_tile.git
cd mod_tile
chmod 777 -R mod_tile
./autogen.sh

./configure
make

make install
make install-mod_tile
ldconfig


git clone https://github.com/gravitystorm/openstreetmap-carto.git
wget -c $Raw_Database_URL

exit

fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile


cd /etc/ssh/

cat <<EOF >ssh_config
ServerAliveInterval 60
EOF

cd -
cd openstreetmap-carto
sudo -u $postgres_user osm2pgsql --slim -d gis -C 3600 --hstore -S openstreetmap-carto.style ../Punjab.pbf

python scripts/get-shapefiles.py

touch style.xml
chmod 777 style.xml

carto project.mml > style.xml
cd ..
chmod 777 conf_osm_16.04.sh 
source ./conf_osm_16.04.sh

exit


