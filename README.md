# Docker virtual environment for Bitrix24

## Purpose
This product provides full virtual environment for quickly deploying a Bitrix website. Has been 'invented' because the official virtual environment image was behaving incorrectly and lacked optimization.

## How it works
The image creates multiple containers on your host via docker-compose and uses them to run your website. The virtual environment is fully independent from the host, only Docker is required. The image uses a prebuilt nginx web server, that maps to ports 80 and 443 on host and serves content directly.

## Contents
- __nginx__
    Open web server, compiled with pagespeed support for on-server optimization.
- __php-fpm__
    PHP 7.1 fpm. Currently this is the latest version that Bitrix supports.
- __msmtp__
    Mail client, used for sending mail from Bitrix site. Included in the `php-fpm` image.
- __memcached__
    Caching server. Currently not used, need implementation in the configs and testing.
- __mysql__
    MySQL 5.7, configured for Bitrix.

## Requirements
- Docker
- Docker-compose
- Open ports 80 and 443

## Structure
- docker-compose.yml
    Main configuration file
- mysql 5.7
    Dockerfile with official MySQL image and some optimizations
- php-7.1-fpm
    Dockerfile with PHP 7.1 fpm with several required additional modules and config for UTF-8
- nginx-pagespeed 
    nginx 1.16.0 web server with pagespeed support
    - .env - provides general configuration options for nginx
    - config - nginx configuration files, copied into image when doing `docker-compose build`
- home
    - bitrix
        The following directory layout is supposed to be present at your local machine at /home/bitrix/
        - mail
            Includes a sample msmtprc. Mapping: /home/bitrix/mail/msmtprc:/etc/msmtprc om php container.
        - mysql
            Target container: mysql
            Mapping: /home/bitrix/mysql:/var/lib/mysql
            Warning! This directory needs to be empty of first startup, otherwise mysql will fail to launch.
        - nginx
            Target container: nginx
            Mapping: /home/bitrix/nginx:/etc/nginx
            Contains example configs.
            - sites-available: all available configs
            - sites-enabled: only those configs that are currently required
                How to correctly enable a site config:
                    `cd /home/bitrix/nginx/sites-enabled`
                    `ln -s ../sites-available/site_config.conf site_config.conf`
        - ssl
            Your SSL certs.
            Target container: nginx
            Mapping: /home/bitrix/ssl:/etc/nginx/ssl
        - www
            Directory with Bitrix website.
            Target containers: nginx, php, mysql
            Mapping: /home/bitrix/www:/var/www/html
## Installation

- ##### Install `docker` and `docker-compose` on your host.
- ##### `cd path-with-bitrix-docker`
- ##### `cp -r home/bitrix /home/bitrix`
- ##### Edit configuration files in `/home/bitrix/` to satisfy your requirements.
- ##### Bitrix site installation
    1. __Manual (recommended).__ Copy your Bitrix website files and the database backup in `.sql` format to `/home/bitrix/www/`.
    2. __Automatic.__ Get an official `restore.php` from 1C website and copy it to `/home/bitrix/www/`. Be aware that automatic restorations often result in bugs and incorrect restorations.
- ##### Building and running
    - ##### Building server
        `docker-compose build`
    - ##### Running server
        `docker-compose up -d`
    - ##### Restoring database
        1. __Automatic.__ Restored with standard `restore.php` script.
        2. __Manual (recommended).__ See below.

## How to restore MySQL backup

1. Place backed `.sql` file at `/home/bitrix/www/`. This place is mapped to `/var/www/html` on our mysql docker container.
2. Restoration of database:
    2.1. `docker ps` and detect the id of our mysql container
    2.2. `docker exec -it MYSQL_CONTAINER_ID_HERE /bin/bash`
    ##### Now we need to create a database and a user for it
    2.3. `mysql -u root -p`
    2.4. enter our mysql password
    ##### Adding database
    2.5. create database DATABASE_NAME character set utf8 collate utf8_unicode_ci;
    ##### Create user
    [//]: # (Watch the syntax closely. Mysql 8.0 has changed it a bit.)
    [//]: # (create user 'USER_NAME@%' blablabla; will result in username set to USER_NAME@%)
    2.6. `create user 'USER_NAME' identified by 'USER_PASSWORD';`
    ##### Adjust privileges
    Syntax explained: `grant all privileges on DATABASE_NAME . TABLE_NAME to 'USER_NAME';` where we have to select all tables
    2.7. `grant all privileges on DATABASE_NAME . * to 'USER_NAME';`
    2.8. `flush privileges;`
    2.9. `exit;`
    ##### Actually restore database
    2.10. `mysql -u root -p DATABASE_NAME < /var/www/html/DATABASE_FILE.sql`
