#!/bin/bash
set -e

# Ensure the data directory exists
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo ">> Initializing database..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null
fi

# Start MariaDB temporarily
echo ">> Starting MariaDB for initial configuration..."
mysqld_safe --skip-networking &
pid="$!"

# Wait for it to start
for i in {30..0}; do
    if mysqladmin ping >/dev/null 2>&1; then
        break
    fi
    echo "   Waiting for MariaDB to start..."
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "Error: MariaDB did not start"
    exit 1
fi

# We read passwords from secrets
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
USER_PASSWORD=$(cat /run/secrets/db_password)

# Initial configuration
echo ">> Configuring database and user..."
mysql -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
    REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${MARIADB_USER}'@'%';
    GRANT SELECT, INSERT ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;

    USE ${MARIADB_DATABASE};

    CREATE TABLE IF NOT EXISTS test (
        id INT AUTO_INCREMENT PRIMARY KEY,
        autor VARCHAR(50) NOT NULL,
        content TEXT NOT NULL,
        creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    INSERT INTO test (autor, content) VALUES
        ('Ana', 'Hello world from Inception 🚀'),
        ('ChatGPT', 'DB works');
EOSQL

# Temporarily stop MariaDB
mysqladmin -uroot -p"${ROOT_PASSWORD}" shutdown

# Start in foreground (container mode)
echo ">> MariaDB started successfully, ready to receive connections."
exec mysqld_safe
