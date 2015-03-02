#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# LAMP on Docker
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"

DB_CONTAINER_NAME="mysql56"
PHP_FPM_CONTAINER_NAME="php53-fpm"
PHP_FPM_HOST_PORT="$(sudo docker inspect --format="{{.NetworkSettings.IPAddress}}:9000" "${PHP_FPM_CONTAINER_NAME}")"

sudo docker run --name "${CONTAINER_NAME}" -p 8053:80 -d -t --volumes-from "data" \
--link "${PHP_FPM_CONTAINER_NAME}":"php" --link "${DB_CONTAINER_NAME}":"db" \
"devmachine:${CONTAINER_NAME}-image" -DFOREGROUND \
-c "FastCgiWrapper Off" \
-c "SetEnv DOCKER_CONTAINER ${PHP_FPM_CONTAINER_NAME}" \
-c "<IfModule mod_fastcgi.c>" \
-c "    DirectoryIndex index.html index.shtml index.cgi index.php" \
-c "    # http://www.webmasterworld.com/apache/4557229.htm - this approach is deprecated in favor of using AddHandler" \
-c "    #AddType application/x-httpd-php .php" \
-c "    AddHandler application/x-httpd-php .php" \
-c "    Action application/x-httpd-php /error-php-fpm-did-not-handle-the-connection" \
-c "    # the path is virtual, but the directory should be present - /var/lib/apache2/fastcgi is by default already present if you install fastcgi mod" \
-c "    Alias /error-php-fpm-did-not-handle-the-connection /var/lib/apache2/fastcgi/php5.fcgi" \
-c "    # throws error if user/group settings are added: [warn] FastCGI: there is no fastcgi wrapper set, user/group options are ignored" \
-c "    FastCgiExternalServer /var/lib/apache2/fastcgi/php5.fcgi -host ${PHP_FPM_HOST_PORT} -idle-timeout 5 -flush -pass-header Authorization" \
-c "    <LocationMatch \"/(ping|status)\">" \
-c "        SetHandler application/x-httpd-php-virtual" \
-c "        Action application/x-httpd-php-virtual /error-php-fpm-did-not-handle-the-connection virtual" \
-c "    </LocationMatch>" \
-c "</IfModule>"
