source $(dirname "$0")/config.sh
sudo ssh-keygen -R $server_name
ssh-keygen -R $server_name
cat "$(dirname "$0")/config.sh" "$(dirname -- "$0")/restart_app.sh" > "$(dirname -- "$0")/compiled/restart_app.sh"
ssh 'root@'$server_name 'bash -s' < "$(dirname -- "$0")/compiled/restart_app.sh"