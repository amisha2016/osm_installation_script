#!/bin/bash
source ./install.conf
<<"COMMENT"
OSM Configuration Script
COMMENT

mkdir -p /home/$postgres_user/public_html/store_tiles
chown -R $postgres_user:$postgres_user /home/$postgres_user/public_html/store_tiles
cd /usr/local/etc/

cat <<EOF >renderd.conf
[renderd]
socketname=/var/run/renderd/renderd.sock
num_threads=4
tile_dir=$tile_stor_dir
stats_file=/var/run/renderd/renderd.stats

[mapnik]
plugins_dir=/usr/lib/mapnik/3.0/input

font_dir=/usr/share/fonts/truetype/
font_dir_recurse=1

[default]
URI=/~$postgres_user/osm_tiles/
TILEDIR=$tile_stor_dir
XML=$xml_style_path
HOST=$domain_name
TILESIZE=256
MAXZOOM=20
CORS=*
EOF


cp ~/src/mod_tile/debian/renderd.init /etc/init.d/renderd
chmod a+x /etc/init.d/renderd

cd /etc/init.d

sed -i 's|DAEMON=.*|DAEMON=/usr/local/bin/$NAME|' renderd
sed -i 's|DAEMON_ARGS=.*|DAEMON_ARGS="-c /usr/local/etc/renderd.conf"|' renderd
sed -i 's|RUNASUSER=.*|RUNASUSER='$postgres_user'|' renderd


mkdir -p /var/lib/mod_tile
chown $postgres_user:$postgres_user /var/lib/mod_tile

mkdir /var/run/renderd
 chown $postgres_user /var/run/renderd
systemctl daemon-reload
systemctl start renderd
systemctl enable renderd

cd /etc/apache2/mods-available/

cat <<EOF >mod_tile.load
LoadModule tile_module /usr/lib/apache2/modules/mod_tile.so
EOF

ln -s /etc/apache2/mods-available/mod_tile.load /etc/apache2/mods-enabled/

cd  /etc/apache2/sites-enabled/

sed -i 's|ServerAdmin webmaster@localhost|ServerAdmin webmaster@localhost\nLoadTileConfigFile /usr/local/etc/renderd.conf\nModTileRenderdSocketName /var/run/renderd/renderd.sock\n# Timeout before giving up for a tile to be rendered\nModTileRequestTimeout 0\n# Timeout before giving up for a tile to be rendered that is otherwise missing\nModTileMissingRequestTimeout 30|' 000-default*.conf

service nginx stop
/etc/init.d/renderd restart

systemctl restart apache2

