
# set root and user
echo "root:${root_password}" | chpasswd
useradd -p $(openssl passwd -1 $user_password) $user_name
usermod -aG sudo $user_name

# main install
apt-get update upgrade
apt-get install nginx -y
apt-get install python3-dev -y
apt-get install python3-pip -y
apt-get install vsftpd -y
apt-get install curl -y
apt-get install python-software-properties -y
apt-get install dialog apt-utils -y


add-apt-repository ppa:ondrej/php -y
apt-get update
apt-get install php7.0 php7.0-fpm php7.0-gd php7.0-mysql php7.0-cli php7.0-common php7.0-curl php7.0-opcache php7.0-json -y
apt-get install php-mbstring php-gettext -y
apt-get install php7.0-mbstring -y


sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${db_root_password}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${db_root_password}"
apt-get install mysql-server -y


service mysql restart
apt-get update upgrade
apt-get install phpmyadmin -y


pip3 install --upgrade pip setuptools -y
pip3 install flask
pip3 install pystache
pip3 install gunicorn
pip3 install beautifulsoup4
pip3 install regex

# clone app repo
cd /var/www/
git clone "$git_app_repo"
cd ${app_name}

ln -s /usr/share/phpmyadmin "/var/www/${app_name}/phpmyadmin"


apt-get -f remove
apt-get install -f

# node js
# apt-get remove nodejs -y

curl -sL https://deb.nodesource.com/setup_10.x | -E bash -
apt-get install nodejs -y
apt-get install build-essential
#npm init -y


# npm
# npm install express --save
# npm install body-parser --save
# npm install express-session --save
# npm install cookie-parser --save
# npm install socket.io --save
# npm install chokidar --save

npm install webpack --save
npm install webpack-cli --save
npm install babel-core babel-loader babel-preset-env --save
npm install style-loader css-loader stylus-loader --save
npm install node-sass sass-loader --save
npm i -D uglifyjs-webpack-plugin
npm install extract-text-webpack-plugin@next --save
npm install babel-cli babel-preset-es2015 --save
npm install stylus --save
npm install node-watch --save
npm install fs --save

# apt install node-stylus -y
# npm install walk --save
# npm install babel-cli babel-preset-es2015 --save
# npm install stylus --save
# npm install css2stylus --save
# npm install -g glob --save
# npm install -g sax --save
# npm install -g debug --save
# npm install -g mkdirp --save
#npm install jquery --save
#npm install mustache --save
#npm install socket.io --save



cat >"/var/www/${app_name}/config_package_json.py" <<EOL
import json
filename = "package.json"
with open(filename) as f:  
	package_json = json.loads(f.read())
package_json['scripts'] = { 
	"dev": "NODE_ENV=dev webpack --mode development", 
	"prod": "webpack --mode production" 
}
file = open(filename, "w")
file.write(json.dumps(package_json, indent=4)) 
file.close()
EOL
python3 config_package_json.py

# remove default site
rm -r /var/www/html
rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

uri='$uri'
fastcgi_param='$document_root$fastcgi_script_name'

# server config
cat >"/etc/nginx/sites-available/${app_name}" <<EOL
server {
	listen 80;
	server_name ${site_name};
	location / {
		proxy_pass http://127.0.0.1:5000;
		proxy_redirect off;
	}
	location /app {
		alias /var/www/${app_name}/app;
	}
	location /public {
		alias /var/www/flask_app/public;
	}
	location /dist {
		alias /var/www/flask_app/dist;
	}
	location /phpmyadmin {
		root /usr/share/;
		index index.php index.html index.htm;
		location ~ ^/phpmyadmin/(.+\.php)$ {
			try_files $uri =404;
			root /usr/share/;
			fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
			fastcgi_index index.php;
			fastcgi_param SCRIPT_FILENAME $fastcgi_param;
			include /etc/nginx/fastcgi_params;
		}
		location ~* ^/phpmyadmin/(.+\.(jpg|jpeg|gif|css|png|js|ico|html|xml|txt))$ {
			root /usr/share/;
		}
	}
	location /phpMyAdmin {
		rewrite ^/* /phpmyadmin last;
	}
}
EOL
ln -s "/etc/nginx/sites-available/${app_name}" "/etc/nginx/sites-enabled"

# wsgi run app
cat >"/var/www/${app_name}/wsgi.py" <<EOL
from app import app
if __name__ == "__main__":
	app.run()
EOL

# give user right and become user
chown -R ${user_name}:${user_name} /var/www/${app_name}

# reload server
service nginx restart

# add https
# add-apt-repository ppa:certbot/certbot
# apt-get update
# apt-get install python-certbot-nginx -y
# systemctl reload nginx
# certbot --non-interactive --redirect --agree-tos --nginx -m ${email_ssl} -d ${site_name}

# run app with gunicorn
cd "/var/www/${app_name}"
pkill gunicorn
npm run dev &
gunicorn --bind "0.0.0.0:${port}" wsgi:app --reload --error-logfile "/var/www/${app_name}/error/python.txt"

