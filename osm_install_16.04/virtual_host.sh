#!/bin/bash
source ./install.conf


mkdir -p /home/$postgres_user/public_html
chmod 711 /home
chmod 711 /home/$postgres_user
chmod 755 /home/$postgres_user/public_html
chown -R $postgres_user:$postgres_user /home/$postgres_user/

<<"COMMENT"
var=$(awk '{for(i=1;i<=2;i++) if ($i=="ServerName") print $(i+1)}' /etc/apache2/sites-available/000-default*.conf)
echo "q=$var"
if [ !$var ];then
var="localhost"
fi


cd /etc/apache2/sites-available
cat <<EOF >$postgres_user.conf
<VirtualHost *:80>
ServerName $postgres_user.$var
DocumentRoot /home/$postgres_user/public_html
ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

COMMENT

<<"COMMENT"
cat <<EOF >$postgres_user-le-ssl.conf
<IfModule mod_ssl.c>
<VirtualHost *:80>
    ServerName $postgres_user.$var
    Redirect "/" "https://$postgres_user.$var/"
</VirtualHost>

<VirtualHost *:443>
    ServerName $postgres_user.$var
    DocumentRoot /home/$postgres_user/public_html
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
SSLCertificateFile /etc/letsencrypt/live/$postgres_user.$var/fullchain.pem
SSLCertificateKeyFile /etc/letsencrypt/live/$postgres_user.$var/privkey.pem
Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
</IfModule>
EOF
COMMENT

cd /etc/apache2/mods-available
cat <<EOF >userdir.conf
<IfModule mod_userdir.c>
        UserDir public_html
        UserDir disabled root
        <Directory /home/*/public_html>
                AllowOverride FileInfo AuthConfig Limit Indexes
                Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec
                <Limit GET POST OPTIONS PROPFIND>
                     Require all granted
                </Limit>
                <LimitExcept GET POST OPTIONS PROPFIND>
                     Require all granted
                </LimitExcept>
        </Directory>
</IfModule>
EOF

cd /etc/apache2/mods-enabled
ln -s ../mods-available/userdir.conf userdir.conf
ln -s ../mods-available/userdir.load userdir.load
a2enmod userdir
/etc/init.d/apache2 restart 

<<"COMMENT"
a2ensite '$postgres_user'.conf
a2ensite '$postgres_user'-le-ssl.conf

icd /etc
cat <<EOF >$postgres_user_hosts.txt
$ip_address $postgres_user.$var 
127.0.0.1 localhost
EOF
cat $postgres_user_hosts.txt >> hosts
service apache2 restart

COMMENT

