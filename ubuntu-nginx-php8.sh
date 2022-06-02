#!/bin/bash

#Edite aqui o site que deseja consigurar
SITE_NAME=listapix.com.br

sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install software-properties-common -y

sudo add-apt-repository ppa:ondrej/php -y && sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt-get update 

sudo apt install php-fpm wget unzip zip git php-common php-mysql php-cgi php-mbstring php-curl php-gd php-xml php-xmlrpc php-pear php-zip curl nginx -y

sudo usermod -aG sudo $USER

CONFIG_FILE="${SITE_NAME}.conf"

cat >> $CONFIG_FILE << EOF
server {
    listen 80;
    listen [::]:80;

    server_name  _ ;

    root /var/www/${SITE_NAME}/public;

    index index.php index.html index.htm;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;

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

if [ -f /etc/nginx/sites-enabled/default ];
  then sudo rm /etc/nginx/sites-enabled/default; 
fi

#sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/${SITE_NAME}

sudo cp ./${SITE_NAME} /etc/nginx/sites-available/${SITE_NAME}
sudo ln -s /etc/nginx/sites-available/${SITE_NAME} /etc/nginx/sites-enabled/

sudo mkdir -p "/var/www/${SITE_NAME}/public"

sudo chown -R $USER:www-data /var/www/${SITE_NAME}/
sudo chmod -R 750 /var/www/${SITE_NAME}/
sudo chmod -R g+s /var/www/${SITE_NAME}/

cd /var/www/${SITE_NAME}


sudo systemctl enable nginx

sudo service nginx restart


sudo wget https://getcomposer.org/download/latest-2.2.x/composer.phar -O /usr/bin/composer
sudo chmod +x /usr/bin/composer
