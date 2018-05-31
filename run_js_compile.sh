source $(dirname "$0")/config.sh
action='js_compile'
sudo ssh-keygen -R $server_name
ssh-keygen -R $server_name
cat "$(dirname "$0")/config.sh" "$(dirname -- "$0")/${action}.sh" > "$(dirname -- "$0")/compiled/${action.sh"
ssh $user_name'@'$server_name 'bash -s' < "$(dirname -- "$0")/compiled/${action}.sh"