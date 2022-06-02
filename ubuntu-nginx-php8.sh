#!/bin/bash

#Edite aqui o site que deseja consigurar
SITE_NAME=listapix.com.br

sudo apt-get update && sudo apt-get upgrade -y
sudo add-apt-repository ppa:ondrej/php -y && sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt-get update 

sudo apt install php-fpm git php-common php-mysql php-cgi php-mbstring php-curl php-gd php-xml php-xmlrpc php-pear php-zip curl nginx -y


#sudo touch /etc/nginx/sites-available/${SITE_NAME}

CONFIG_FILE=${SITE_NAME}

cat >> $CONFIG_FILE << EOF
server {
    listen 80;
    listen [::]:80;

    server_name  _ ;

    root /var/www/${SITE_NAME}/public;

    index index.php index.html index.htm;

    location / {
        try_files $uri $uri/ /index.php?$args;
    }
    
    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        #change to php version instaled
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
    }
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires max;
        log_not_found off;
    }
}
EOF

sudo unlink /etc/nginx/sites-enabled/default
#sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/${SITE_NAME}
cp ./${SITE_NAME} /etc/nginx/sites-available/${SITE_NAME}
sudo ln -s /etc/nginx/sites-available/${SITE_NAME} /etc/nginx/sites-enabled/

mkdir /var/www/${SITE_NAME}
mkdir /var/www/${SITE_NAME}/public

sudo chown -R ubuntu:www-data /var/www/${SITE_NAME}/
chmod -R 750 /var/www/${SITE_NAME}/
chmod -R g+s /var/www/${SITE_NAME}/

cd /var/www/${SITE_NAME}


sudo systemctl enable nginx

sudo service nginx restart


sudo php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo php composer-setup.php
sudo php -r "unlink('composer-setup.php');"
sudo sudo mv composer.phar /usr/local/bin/composer


