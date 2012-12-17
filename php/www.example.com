server {

    listen 80;

    server_name   www.example.com;
    root         /var/www/www.example.com/public;

    include      /etc/nginx/global/restrictions.conf;

    location / {
        index  index.php index.html index.htm;
    }

    # Directives to send expires headers and turn off 404 error logging
    location ~* \.(js|css|png|jpg|jpeg|gif|ico)$ {
        expires        24h;
        log_not_found  off;
    }

    include      /etc/nginx/global/php-##PHP_VERSION_STRING##.conf;
}
