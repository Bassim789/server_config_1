source $(dirname "$0")/config.sh
sudo ssh-keygen -R $server_name
ssh-keygen -R $server_name
cat "$(dirname "$0")/config.sh" "$(dirname -- "$0")/watcher.sh" > "$(dirname -- "$0")/compiled/watcher.sh"
ssh $user_name'@'$server_name 'bash -s' < "$(dirname -- "$0")/compiled/watcher.sh"