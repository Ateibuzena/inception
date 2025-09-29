#!/bin/bash
set -e

# Variables de entorno (de tu .env o docker-compose)
DB_NAME=${WORDPRESS_DB_NAME}
DB_USER=${WORDPRESS_DB_USER}
DB_PASSWORD=${WORDPRESS_DB_PASSWORD}
DB_HOST=${WORDPRESS_DB_HOST}

SITE_URL=${WORDPRESS_SITE_URL:-https://localhost}
SITE_TITLE=${WORDPRESS_SITE_TITLE:-MyPage}
ADMIN_USER=${WORDPRESS_ADMIN_USER:-user}
ADMIN_PASSWORD=${WORDPRESS_ADMIN_PASSWORD:-1}
ADMIN_EMAIL=${WORDPRESS_ADMIN_EMAIL:-user@example.com}

# Descarga WordPress si no existe
if [ ! -f index.php ]; then
    echo ">> Descargando WordPress..."
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    chmod +x wp-cli.phar
    rm latest.tar.gz
fi

# Copia wp-config si no existe
if [ ! -f wp-config.php ]; then
    echo ">> Configurando wp-config.php..."
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
    sed -i "s/username_here/${DB_USER}/" wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/${DB_HOST}/" wp-config.php

    # Llaves de seguridad (random)
    #curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
fi

# Instalación automática si WordPress no está instalado
if ! wp core is-installed --path=/var/www/ --allow-root; then
    echo ">> Instalando WordPress..."
    wp core install \
        --url="$SITE_URL" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --path=/var/www/ \
        --allow-root
fi

# Asegurar permisos
chown -R www-data:www-data /var/www/

# Arrancamos PHP-FPM en primer plano
exec php-fpm8.2 -F