server_name='vps324508.ovh.net'
ip='37.74.172.99'
sudo ssh-keygen -R $server_name
ssh 'root@'$server_name 'bash -s' < "$(dirname -- "$0")/web_install.sh"