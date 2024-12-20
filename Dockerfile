FROM php:8.3-apache
LABEL org.opencontainers.image.authors="ismo@ivuorinen.com"

# Utilities
RUN apt-get update \
    && apt-get -y install \
       apt-transport-https=2.6.1 \
       git=1:2.39.2-1.1 \
       curl=7.88.1-10+deb12u5 \
       vim=2:9.0.1378-2 \
       --no-install-recommends \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

# SimpleSAMLphp
ARG SIMPLESAMLPHP_VERSION=2.1.3
ADD "https://github.com/simplesamlphp/simplesamlphp/releases/download/v$SIMPLESAMLPHP_VERSION/simplesamlphp-$SIMPLESAMLPHP_VERSION.tar.gz" /tmp/simplesamlphp.tar.gz
RUN tar xzf /tmp/simplesamlphp.tar.gz -C /tmp \
    && rm -f /tmp/simplesamlphp.tar.gz \
    && mv /tmp/simplesamlphp-* /var/www/simplesamlphp \
    && touch /var/www/simplesamlphp/modules/exampleauth/enable
COPY config/simplesamlphp/config.php /var/www/simplesamlphp/config
COPY config/simplesamlphp/authsources.php /var/www/simplesamlphp/config
COPY config/simplesamlphp/saml20-sp-remote.php /var/www/simplesamlphp/metadata
COPY config/simplesamlphp/server.crt /var/www/simplesamlphp/cert/
COPY config/simplesamlphp/server.pem /var/www/simplesamlphp/cert/

# Apache
COPY config/apache/ports.conf /etc/apache2
COPY config/apache/simplesamlphp.conf /etc/apache2/sites-available
COPY config/apache/cert.crt /etc/ssl/cert/cert.crt
COPY config/apache/private.key /etc/ssl/private/private.key
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf \
    && a2enmod ssl \
    && a2dissite 000-default.conf default-ssl.conf \
    && a2ensite simplesamlphp.conf

# Set work dir
WORKDIR /var/www/simplesamlphp

# General setup
EXPOSE 8080 8443
