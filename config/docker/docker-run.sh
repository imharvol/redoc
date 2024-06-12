#!/bin/sh

set -e

sed -i -e "s|%PAGE_TITLE%|$PAGE_TITLE|g" /usr/share/nginx/html/index.html
sed -i -e "s|%PAGE_FAVICON%|$PAGE_FAVICON|g" /usr/share/nginx/html/index.html
sed -i -e "s|%BASE_PATH%|$BASE_PATH|g" /usr/share/nginx/html/index.html
sed -i -e "s|%SPEC_URL%|$SPEC_URL|g" /usr/share/nginx/html/index.html
sed -i -e "s|%REDOC_OPTIONS%|${REDOC_OPTIONS}|g" /usr/share/nginx/html/index.html
sed -i -e "s|\(listen\s*\) [0-9]*|\1 ${PORT}|g" /etc/nginx/nginx.conf

if { [ -n "$USER_NAME" ] && [ -z "$USER_PASSWORD" ]; } || { [ -z "$USER_NAME" ] && [ -n "$USER_PASSWORD" ]; }; then
    echo "Warning: Both USER_NAME and USER_PASSWORD must be set, or neither. Ignoring USER_NAME and USER_PASSWORD."
fi

if [[ -n "$USER_NAME" && -n "$USER_PASSWORD" ]]; then
    htpasswd -b -c /etc/nginx/.htpasswd "$USER_NAME" "$USER_PASSWORD" > /dev/null 2>&1

    AUTH_DIRECTIVES="      auth_basic \"Restricted Area\";\n      auth_basic_user_file /etc/nginx/.htpasswd;\n"

        sed -i "/location \/ {/a\\
$AUTH_DIRECTIVES" /etc/nginx/nginx.conf
fi

exec nginx -g 'daemon off;'
