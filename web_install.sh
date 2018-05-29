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
cd /var/www
git clone git://github.com/Bassim789/flask_app.git
echo "run app"
python3 flask_app/app.py