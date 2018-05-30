
# set root and user
echo "root:${new_password}" | chpasswd
useradd -p $(openssl passwd -1 $user_password) $user_name
usermod -aG sudo $user_name

# main install
apt-get update
apt-get install nginx -y
apt-get install python3-dev -y
apt-get install python3-pip -y
apt-get install vsftpd -y
pip3 install --upgrade pip setuptools -y
pip3 install flask
pip3 install pystache
pip3 install gunicorn


cd /var/www/
# clone app repo
git clone "$git_app_repo"
# give user right and become user
echo "chown"
chown -R ${user_name}:${user_name} /var/www/
su -E ${user_name}
whoami
echo "app_name: ${app_name}"
# server config
sudo cat >"/etc/nginx/sites-available/${app_name}" <<EOL
server {
	listen 80;
	server_name ${site_name};
	location / {
		proxy_pass http://127.0.0.1:${port};
	}
}
EOL
echo $app_name
echo $server_ip
sudo ln -s "/etc/nginx/sites-available/${app_name}" "/etc/nginx/sites-enabled"

# wsgi run app
sudo cat >"/var/www/${app_name}/wsgi.py" <<EOL
from app import app
if __name__ == "__main__":
	app.run()
EOL

# remove default site
sudo rm -r /var/www/html
sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

# reload server
sudo service nginx start
sudo service nginx restart

# add https
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install python-certbot-nginx -y
sudo systemctl reload nginx
sudo certbot --non-interactive --redirect --agree-tos --nginx -m ${email_ssl} -d ${site_name}

# run app with gunicorn
cd "/var/www/${app_name}"
sudo gunicorn --bind "0.0.0.0:${port}" wsgi:app --reload
