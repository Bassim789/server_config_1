
server_name='vps324508.ovh.net'
ip='37.74.172.99'

echo !! remove previous ssh connexion problem
sudo ssh-keygen -R $server_name

echo !! execute install script
ssh 'root@'$server_name 'bash -s' < web_install.sh