#!/bin/sh

# Create directories for bitrix
# database dir
mkdir -p /home/bitrix/mysql
# bitrix files dir
mkdir -p /home/bitrix/www

# Set owners and permissions
# Add mysql user and group if missing
adduser --system --no-create-home --disabled-password --shell /bin/false mysql
addgroup --system mysql
usermod -aG mysql mysql
chown -R mysql:mysql /home/bitrix/mysql
chown -R www-data:www-data /home/bitrix/www