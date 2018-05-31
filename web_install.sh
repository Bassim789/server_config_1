
# set root and user
echo "root:${root_password}" | chpasswd
useradd -p $(openssl passwd -1 $user_password) $user_name
usermod -aG sudo $user_name

# main install
apt-get update
apt-get install nginx -y
apt-get install python3-dev -y
apt-get install python3-pip -y
apt-get install vsftpd -y
apt-get install curl -y
apt-get install python-software-properties -y
pip3 install --upgrade pip setuptools -y
pip3 install flask
pip3 install pystache
pip3 install gunicorn

# clone app repo
cd /var/www/
git clone "$git_app_repo"
cd ${app_name}

# node js
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
apt-get install nodejs -y
apt install node-stylus -y
npm init -y
npm install walk --save
npm install babel-cli babel-preset-es2015 --save
npm install stylus --save
npm install css2stylus --save
npm install -g glob --save
npm install -g sax --save
npm install -g debug --save
npm install -g mkdirp --save
npm install express --save
npm install body-parser --save
npm install express-session --save
npm install cookie-parser --save
npm install socket.io --save
npm install chokidar --save

# remove default site
rm -r /var/www/html
rm /etc/nginx/sites-available/default
rm /etc/nginx/sites-enabled/default

# server config
cat >"/etc/nginx/sites-available/${app_name}" <<EOL
server {
	listen 80;
	server_name ${site_name};
	location / {
		proxy_pass http://127.0.0.1:${port};
	}
	location /app {
		alias /var/www/${app_name}/app;
	}
	location /public {
		alias /var/www/flask_app/public;
	}
	location /compiled {
		alias /var/www/flask_app/compiled;
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
chown -R ${user_name}:${user_name} /var/www/

# reload server
service nginx start
service nginx restart

# add https
add-apt-repository ppa:certbot/certbot
apt-get update
apt-get install python-certbot-nginx -y
systemctl reload nginx
certbot --non-interactive --redirect --agree-tos --nginx -m ${email_ssl} -d ${site_name}

# run app with gunicorn
cd "/var/www/${app_name}"
pkill gunicorn
gunicorn --bind "0.0.0.0:${port}" wsgi:app --reload