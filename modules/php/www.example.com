server {

    listen 80;

    server_name   www.example.com;
    root          /var/www/www.example.com/public;
    index         index.php index.html index.htm;

    include       /etc/nginx/global/restrictions.conf;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # Directives to send expires headers and turn off 404 error logging
    location ~* \.(css|js|swf|xml|pdf|bmp|gif|jpg|jpeg|jpe|png|tif|eot|svg|ttf|woff)$ {
        expires        24h;
        log_not_found  off;
    }

    include      /etc/nginx/global/php-##PHP_VERSION_STRING##.conf;
}
