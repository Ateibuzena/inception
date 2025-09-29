FROM debian:oldstable

# Instalamos PHP, extensiones necesarias, curl y mariadb-client
RUN apt-get update && \
    apt-get install -y \
        php8.2-fpm php8.2-mysql php8.2-cli php8.2-curl php8.2-gd php8.2-mbstring \
        php8.2-xml php8.2-zip curl unzip mariadb-client git procps && \
    rm -rf /var/lib/apt/lists/*

# Instalar WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Creamos directorio de WordPress y permisos
RUN mkdir -p /var/www/
WORKDIR /var/www/

RUN sed -i "s/listen = .*/listen = 0.0.0.0:9000/" /etc/php/8.2/fpm/pool.d/www.conf

# Copiamos script de inicialización
COPY ./tools/makefile.sh /usr/local/bin/makefile.sh
RUN chmod +x /usr/local/bin/makefile.sh

# Exponemos puerto (aunque lo sirve Nginx)
EXPOSE 9000

# Script que arranca PHP-FPM y configura WordPress
ENTRYPOINT ["/usr/local/bin/makefile.sh"]