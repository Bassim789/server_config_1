app_name='flask_app'
site_name='37.74.172.99'
secret_key='5435gdfsgfv4665v4t'

apt-get update
apt-get install apache2 -y
apt-get install python3-dev -y
apt-get install python3-pip -y
apt-get install libapache2-mod-wsgi -y
pip3 install --upgrade pip setuptools -y
pip3 install flask
pip3 install pystache
pip3 install uwsgi
a2enmod wsgi 
cd /var/www/
git clone git://github.com/Bassim789/$app_name.git

nano /etc/apache2/sites-available/$app_name.conf

cat >/etc/apache2/sites-available/$app_name.conf <<EOL
<VirtualHost *:80>
	ServerName ${site_name}
	ServerAdmin admin@${site_name}
	WSGIScriptAlias / /var/www/${app_name}/${app_name}.wsgi
	<Directory /var/www/${app_name}/>
		Order allow,deny
		Allow from all
	</Directory>
	Alias /static /var/www/${app_name}/static
	<Directory /var/www/${app_name}/static/>
		Order allow,deny
		Allow from all
	</Directory>
	ErrorLog ${APACHE_LOG_DIR}/error.log
	LogLevel warn
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOL

cat >/var/www/$app_name/$app_name.wsgi  <<EOL
#!/usr/bin/python
import sys
import logging
logging.basicConfig(stream=sys.stderr)
sys.path.insert(0,"/var/www/${app_name}/")

from FlaskApp import app as application
application.secret_key = '${secret_key}'
EOL

sudo a2ensite $app_name

sudo service apache2 restart 

echo "run app"
python3 $app_name/app.py