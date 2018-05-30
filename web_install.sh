app_name='flask_app'

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

/etc/init.d/nginx start
rm "/etc/nginx/sites-enabled/default"
touch "/etc/nginx/sites-available/${app_name}"
ln -s "/etc/nginx/sites-available/${app_name}" "/etc/nginx/sites-enabled/${app_name}"
cat >"/etc/nginx/sites-enabled/${app_name}" <<EOL
server {
	location / {
		proxy_pass http://127.0.0.1:8000;
		proxy_set_header Host $host;
		proxy_set_header X-Real_IP $remote_addr;
	}
}
EOL
cat >"/var/www/${app_name}/wsgi.py" <<EOL
from app import app
if __name__ == "__main__":
	app.run()
EOL
/etc/init.d/nginx restart

cd "/var/www/${app_name}"
echo "run app"
gunicorn --bind 0.0.0.0:5000 wsgi:app
#gunicorn my_app:app
#uwsgi --socket 0.0.0.0:8000 --protocol=http -w wsgi
#python3 $app_name/app.py
