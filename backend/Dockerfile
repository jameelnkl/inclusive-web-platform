FROM php:8.4-apache

RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql pgsql \
    && a2enmod rewrite

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /app

ENV APACHE_DOCUMENT_ROOT=/app/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && printf '<Directory /app/public>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>\n' > /etc/apache2/conf-available/app.conf \
    && a2enconf app

COPY composer.json composer.lock ./
RUN COMPOSER_PROCESS_TIMEOUT=600 composer install --no-interaction --no-scripts --no-autoloader

COPY . .
RUN composer dump-autoload --optimize