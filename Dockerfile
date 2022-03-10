FROM php:8.1-fpm

RUN apt-get update \
  && apt-get install -y \
             apt-utils \
             man \
             curl \
             git \
             bash \
             vim \
             zip unzip \
             acl \
             iproute2 \
             dnsutils \
             fonts-freefont-ttf \
             fontconfig \
             dbus \
             openssh-client \
             sendmail \
             libfreetype6-dev \
             libjpeg62-turbo-dev \
             icu-devtools \
             libicu-dev \
             libmcrypt4 \
             libmcrypt-dev \
             libpng-dev \
             zlib1g-dev \
             libxml2-dev \
             libzip-dev \
             libonig-dev \
             graphviz \
             libcurl4-openssl-dev \
             libssl-dev \
             pkg-config \
             libldap2-dev \
             libpq-dev \
  && pecl install mongodb \
  && echo "extension=mongodb.so" > /usr/local/etc/php/conf.d/mongodb-ext.ini

RUN docker-php-ext-configure intl --enable-intl && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install -j$(nproc) gd && \
    docker-php-ext-install pdo \
        pgsql pdo_pgsql \
        mysqli pdo_mysql \
        intl iconv mbstring \
        zip pcntl \
        exif opcache \
    && docker-php-source delete

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

RUN pecl install -o -f redis \
    &&  rm -rf /tmp/pear \
    &&  docker-php-ext-enable redis

RUN apt-get update \
    && apt-get install -y ffmpeg unzip

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini \
    && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 2G/g' /usr/local/etc/php/php.ini \
    && sed -i 's/max_input_time = 60/max_input_time = 300/g' /usr/local/etc/php/php.ini \
    && sed -i 's/post_max_size = 8M/post_max_size = 2G/g' /usr/local/etc/php/php.ini

RUN mkdir /tmp/ImageMagick \
    && cd /tmp/ImageMagick \
    && curl -L -O https://github.com/ImageMagick/ImageMagick/archive/refs/tags/7.0.11-4.tar.gz \
    && mkdir ImageMagick \
    && tar zxvf 7.0.11-4.tar.gz --strip-components=1 -C ImageMagick \
    && cd ImageMagick \
    && ./configure && make && make install && make clean \
    && cd /tmp && rm -rvf /tmp/ImageMagick/ \
    && mkdir Imagick && cd Imagick \
    && curl -L -O https://github.com/Imagick/imagick/archive/refs/heads/master.zip \
    && unzip master.zip && cd imagick-master \
    && phpize && ./configure \
    && make && make install && make clean \
    && cd /tmp && rm -rvf /tmp/Imagick \
    && docker-php-ext-enable imagick
