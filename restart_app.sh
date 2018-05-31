# run app with gunicorn
cd "/var/www/${app_name}"
pkill gunicorn
gunicorn --bind "0.0.0.0:${port}" wsgi:app --reload