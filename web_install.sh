app_name='flask_app'
server_ip='37.74.172.99'

apt-get update
apt-get install nginx -y
apt-get install python3-dev -y
apt-get install python3-pip -y
pip3 install --upgrade pip setuptools -y
pip3 install flask
pip3 install pystache
pip3 install uwsgi
pip3 install gunicorn
cd /var/www/
git clone "git://github.com/Bassim789/${app_name}.git"
cat >"/etc/nginx/sites-available/${app_name}" <<EOL
server {
	listen 80;
	server_name ${server_ip};
	location / {
		proxy_pass http://127.0.0.1:5000;
	}
}
EOL
ln -s "/etc/nginx/sites-available/${app_name}" "/etc/nginx/sites-enabled"
cat >"/var/www/${app_name}/wsgi.py" <<EOL
from app import app
if __name__ == "__main__":
	app.run()
EOL
rm -r /var/www/html
rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default
service nginx start
cd "/var/www/${app_name}"
gunicorn --bind 0.0.0.0:5000 wsgi:app
#gunicorn my_app:app
#uwsgi --socket 0.0.0.0:8000 --protocol=http -w wsgi
#python3 $app_name/app.py
