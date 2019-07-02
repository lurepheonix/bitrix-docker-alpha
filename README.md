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

    Main configuration file. Set MYSQL_ROOT_PASSWORD there later, it will be used on first launch.

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
                Provides example configs for http, https and redirect of http to https.
                Only http config is enabled by default, as incorrect configs cause nginx errors.
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
    - ##### Change default MySQL password
        Open docker-compose.yml and change the value of variable MYSQL_ROOT_PASSWORD. It sets the main mysql password on first launch.
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
    ##### Creating database and user from a mysql container
    2.1. `docker ps`, then detect the id of mysql container

    2.2. `docker exec -it MYSQL_CONTAINER_ID_HERE /bin/bash` // jump into the container

    2.3. `mysql -u root -p` // login and enter mysql password

    ##### Creating database
    2.4. create database DATABASE_NAME character set utf8 collate utf8_unicode_ci;
    ##### Creating user
    [//]: # (Watch the syntax closely. Mysql 8.0 has changed it a bit.)
    [//]: # (create user 'USER_NAME@%' blablabla; will result in username set to USER_NAME@%)
    2.5. `create user 'USER_NAME' identified by 'USER_PASSWORD';`
    ##### Adjust privileges
    Syntax explained: `grant all privileges on DATABASE_NAME . TABLE_NAME to 'USER_NAME';` // we have to select all tables, so use *

    2.6. `grant all privileges on DATABASE_NAME . * to 'USER_NAME';`

    2.7. `flush privileges;`

    2.8. `exit;`
    ##### Actually restore database
    2.9. `mysql -u root -p DATABASE_NAME < /var/www/html/DATABASE_FILE.sql`
    ##### Fix database credentials and host in Bitrix config
    2.10. Change database credentials to new ones in bitrix/.settings.php and bitrix/php_interface/dbconn.php. Also, change the hostname of sql server to `mysql`.
    ##### Fix permissions for nginx/php
    2.11. `chown -R www-data:www-data /home/bitrix/www/`

### Debugging
    All containers are designed to push logs to /dev/stdout. They can be viewed either by using `docker-compose logs` after launching with `docker-compose up-d`, or you can launch containers with `docker-compose up`.

    You can also jump into the container by using `docker exec -it CONTAINER_ID /bin/bash`.

### Getting a LetsEncrypt certificate
    - Better use Cloudflare free plan.
    - If you still want a cert, jump into the container and install certbot.

### TODO/Known bugs
    - There seem to be some issues with pagespeed - it fails to rewrite resources from time to time. Needs investigating,
    - Need to configure memcached.
    - Currently, pagespeed statistics are exposed into the internet. Need to turn them off/lock them by password.