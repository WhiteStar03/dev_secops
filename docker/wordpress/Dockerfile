ARG VULNERABLE_WORDPRESS_TAG=6.4.3-php8.2-apache
ARG FIXED_WORDPRESS_TAG=6.9.4-php8.2-apache

FROM wordpress:${VULNERABLE_WORDPRESS_TAG} AS vulnerable

RUN set -eux; \
    sed -ri 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf; \
    sed -ri 's/:80>/:8080>/' /etc/apache2/sites-available/000-default.conf

EXPOSE 8080

FROM wordpress:${FIXED_WORDPRESS_TAG} AS fixed

COPY docker/wordpress/apache-security.conf /etc/apache2/conf-available/zz-security-hardening.conf
COPY docker/wordpress/php-security.ini /usr/local/etc/php/conf.d/security-hardening.ini

RUN set -eux; \
    sed -ri 's/Listen 80/Listen 8080/' /etc/apache2/ports.conf; \
    sed -ri 's/:80>/:8080>/' /etc/apache2/sites-available/000-default.conf; \
    a2enmod headers rewrite; \
    a2enconf zz-security-hardening; \
    rm -f /usr/src/wordpress/readme.html /usr/src/wordpress/license.txt; \
    rm -f /usr/src/wordpress/wp-content/plugins/hello.php; \
    rm -rf /usr/src/wordpress/wp-content/plugins/akismet; \
    chown -R www-data:www-data /var/www/html /usr/src/wordpress

USER www-data

EXPOSE 8080
