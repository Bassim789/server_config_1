
echo !! update the server
sudo apt-get update

echo !! install dev, pip, venv
sudo apt-get install python3-dev python3-pip -y

echo !! make sure pip and setuptools are the latest version
pip3 install --upgrade pip setuptools -y

#echo !! go to web folder
#cd /var/www

echo !! clone git repo for flask app perso
git clone git://github.com/Bassim789/flask_app.git

echo !! install flask module
pip3 install flask

echo !! run app
python3 flask_app/app.py

# change default password
#passwd root

# install apache and php
#sudo apt-get install curl
#sudo apt-get install apache2 -y
#sudo apt-get install sendmail -y
#sudo apt-get install php -y
#sudo apt install php libapache2-mod-php

# install python
#sudo apt-get install python3.6

# install virtual env
# sudo apt-get install python3-venv

# create folder
#mkdir $project_name -p
# go to folder
#cd $project_name

#scp 'bassimmatar@'$my_local_ip':'$my_local_path'app.py ../'

# create virtual env
#python3 -m venv venv
#. venv/bin/activate
#pip install Flask gunicorn
#mkdir './'$project_name
#cd ../ #$project_name
#gunicorn $project_name':app'