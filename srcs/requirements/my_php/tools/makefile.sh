#!/bin/bash
set -e

# Environment variables (from your .env or docker-compose)
DB_NAME=${WORDPRESS_DB_NAME}
DB_USER=${WORDPRESS_DB_USER}
DB_PASSWORD=${WORDPRESS_DB_PASSWORD}
DB_HOST=${WORDPRESS_DB_HOST}

SITE_URL=${WORDPRESS_SITE_URL:-https://localhost}
SITE_TITLE=${WORDPRESS_SITE_TITLE:-MyPage}
ADMIN_USER=${WORDPRESS_ADMIN_USER:-user}
ADMIN_PASSWORD=${WORDPRESS_ADMIN_PASSWORD:-1}
ADMIN_EMAIL=${WORDPRESS_ADMIN_EMAIL:-user@example.com}

# Download WordPress if it does not exist
if [ ! -f index.php ]; then
    echo ">> Downloading WordPress..."
    curl -O https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz --strip-components=1
    chmod +x wp-cli.phar
    rm latest.tar.gz
fi

# Copy wp-config if it does not exist
if [ ! -f wp-config.php ]; then
    echo ">> Configuring wp-config.php..."
    cp wp-config-sample.php wp-config.php

    sed -i "s/database_name_here/${DB_NAME}/" wp-config.php
    sed -i "s/username_here/${DB_USER}/" wp-config.php
    sed -i "s/password_here/${DB_PASSWORD}/" wp-config.php
    sed -i "s/localhost/${DB_HOST}/" wp-config.php

    # Security keys (random)
    #curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
fi

# Automatic installation if WordPress is not installed
if ! wp core is-installed --path=/var/www/ --allow-root; then
    echo ">> Installing WordPress..."
    wp core install \
        --url="$SITE_URL" \
        --title="$SITE_TITLE" \
        --admin_user="$ADMIN_USER" \
        --admin_password="$ADMIN_PASSWORD" \
        --admin_email="$ADMIN_EMAIL" \
        --path=/var/www/ \
        --allow-root
fi

# Secure permissions
chown -R www-data:www-data /var/www/

# We start PHP-FPM in the foreground
exec php-fpm8.2 -F