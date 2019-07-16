FROM php:7.1-fpm

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libpng-dev \
        libicu-dev \
        libpq-dev \
        patch

# Patch for pkg-config
ADD https://git.archlinux.org/svntogit/packages.git/plain/trunk/freetype.patch?h=packages/php /tmp/freetype.patch
RUN docker-php-source extract; \
  cd /usr/src/php; \
  patch -p1 -i /tmp/freetype.patch; \
  rm /tmp/freetype.patch

RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) mysqli \
    && docker-php-ext-install -j$(nproc) pdo_mysql \
    && docker-php-ext-install -j$(nproc) opcache \
    && docker-php-ext-install -j$(nproc) intl \
    && pecl install apcu-5.1.5 \
    && docker-php-ext-enable apcu

RUN apt-get install -y msmtp

RUN sed -i 's/; max_input_vars = 1000/max_input_vars = 10000/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/short_open_tag = Off/short_open_tag = On/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 1024M/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/post_max_size = 8M/post_max_size = 1024M/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/;mbstring.internal_encoding =/mbstring.internal_encoding = utf-8/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/;realpath_cache_size = 4096k/realpath_cache_size = 4096k/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/;pcre.backtrack_limit=100000/pcre.backtrack_limit=100000/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/;pcre.recursion_limit=100000/pcre.recursion_limit=100000/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's/;pcre.jit=1/pcre.jit=1/g' /usr/local/etc/php/php.ini-production \
    && sed -i 's|;sendmail_path =|sendmail_path = "/usr/bin/msmtp -t"|g' /usr/local/etc/php/php.ini-production \
    && echo "mbstring.func_overload = 2" >> /usr/local/etc/php/php.ini-production \
    && echo "opcache.revalidate_freq = 0" >> /usr/local/etc/php/php.ini-production

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

RUN echo "* * * * * www-data php /var/www/html/bitrix/modules/main/tools/cron_events.php" >> /etc/crontab