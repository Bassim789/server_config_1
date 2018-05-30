app_name='flask_app'
site_name='37.74.172.99'
secret_key='5435gdfsgfv4665v4t'

apache_log_dir_var='${APACHE_LOG_DIR}'

apt-get update
#apt-get install apache2 -y
apt-get install  nginx -y
apt-get install python3-dev -y
apt-get install python3-pip -y
#apt-get install libapache2-mod-wsgi -y
pip3 install --upgrade pip setuptools -y
pip3 install flask
pip3 install pystache
pip3 install uwsgi
a2enmod wsgi
cd /var/www/
git clone "git://github.com/Bassim789/${app_name}.git"

cat >"/etc/apache2/sites-available/${app_name}.conf" <<EOL
<VirtualHost *:80>
	ServerName ${site_name}
	ServerAdmin webmaster@localhost
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
	ErrorLog ${apache_log_dir_var}/error.log
	LogLevel warn
	CustomLog ${apache_log_dir_var}/access.log combined
</VirtualHost>
EOL

cat >"/var/www/${app_name}/wsgi.py"  <<EOL
from ${app_name} import app
if __name__ == "__main__":
    app.run()
EOL

#service apache2 restart
#a2ensite $app_name
#echo "reload apache"
#systemctl reload apache2
echo "run app"
uwsgi --socket 0.0.0.0:8000 --protocol=http -w wsgi
python3 $app_name/app.py
