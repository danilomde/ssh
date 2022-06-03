#!/bin/bash

#Edite aqui o site que deseja consigurar
DNS=listapix.com.br

SITE_NAME=${1:-${DNS}}
#SITE_NAME=${1:-listapix.com.br}

echo -e "Creating server for \n \t\t ${SITE_NAME}"

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install software-properties-common -y

sudo add-apt-repository ppa:ondrej/php -y && sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt-get update 
sudo apt install php-fpm wget unzip zip git php-common php-sqlite3 php-mysql php-cgi php-mbstring php-curl php-gd php-xml php-xmlrpc php-pear php-zip curl nginx -y

sudo usermod -aG sudo $USER

CONFIG_FILE="${SITE_NAME}.conf"
SERVER_DOMAINS="${SITE_NAME} www.${SITE_NAME}"
APP_PATH="/var/www/${SITE_NAME}"

sudo mkdir -p "${APP_PATH}/public"

if [ ! -f "${APP_PATH}/public/index.php" ]; then
	echo -e "<?php phpinfo(); " |sudo tee ${APP_PATH}/public/index.php
fi

if [ ! -f "${APP_PATH}/public/index.php" ]; then
	echo -e "\nThe file '${APP_PATH}/public/index.php not exists'.\n"
	exit 1;
fi

cat > $CONFIG_FILE << EOF
## INICIO Nginx conf php
server {
    listen 80;
    #    listen 443 ssl;
    server_name ${SERVER_DOMAINS};
    root ${APP_PATH}/public;
    ## Redirecionar para https
    #return 301 https://$host$request_uri;

    index index.php index.html index.htm;
    #    ssl_certificate /etc/nginx/ssl_certs/cert.pem;
    #    ssl_certificate_key /etc/nginx/ssl_certs/cert.key;

    location / {
        #    autoindex on;
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    #    location / {
    #        try_files $uri $uri/ =404;
    #    }

    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
    }

    location ~ /\.ht {
        deny all;
    }

}
## FIM Nginx conf php
EOF

if [ -f /etc/nginx/sites-enabled/default ];
  then sudo rm /etc/nginx/sites-enabled/default; 
fi

#sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/${SITE_NAME}

sudo mv ./${CONFIG_FILE} /etc/nginx/sites-available/${CONFIG_FILE}
sudo ln -s /etc/nginx/sites-available/${CONFIG_FILE} /etc/nginx/sites-enabled/

sudo mkdir -p "${APP_PATH}/public"

sudo chown -R $USER:www-data /var/www/${SITE_NAME}/
sudo chmod -R 750 "${APP_PATH}"
sudo chmod -R g+s "${APP_PATH}"

sudo systemctl enable nginx

sudo service nginx restart

sudo wget https://getcomposer.org/download/latest-2.2.x/composer.phar -O /usr/bin/composer
sudo chmod +x /usr/bin/composer
