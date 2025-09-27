#!/bin/bash
set -e

# Aseguramos que el directorio de datos existe
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo ">> Inicializando base de datos..."
    mysql_install_db --user=mysql --ldata=/var/lib/mysql > /dev/null
fi

# Arrancamos mariadb temporalmente
echo ">> Arrancando MariaDB para configuración inicial..."
mysqld_safe --skip-networking &
pid="$!"

# Esperamos a que arranque
for i in {30..0}; do
    if mysqladmin ping >/dev/null 2>&1; then
        break
    fi
    echo "   Esperando a que MariaDB arranque..."
    sleep 1
done

if [ "$i" = 0 ]; then
    echo "Error: MariaDB no arrancó"
    exit 1
fi

# Leemos contraseñas de los secrets
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
USER_PASSWORD=$(cat /run/secrets/db_password)





# Configuración inicial
echo ">> Configurando base de datos y usuario..."
mysql -uroot <<-EOSQL
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
    CREATE DATABASE IF NOT EXISTS ${MARIADB_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
    CREATE USER IF NOT EXISTS '${MARIADB_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
    GRANT ALL PRIVILEGES ON ${MARIADB_DATABASE}.* TO '${MARIADB_USER}'@'%';
    FLUSH PRIVILEGES;

    USE ${MARIADB_DATABASE};

    CREATE TABLE IF NOT EXISTS mensajes (
        id INT AUTO_INCREMENT PRIMARY KEY,
        autor VARCHAR(50) NOT NULL,
        contenido TEXT NOT NULL,
        creado TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );

    INSERT INTO mensajes (autor, contenido) VALUES
        ('Ana', 'Hola mundo desde Inception 🚀'),
        ('ChatGPT', 'Todo está listo, la DB funciona.');
EOSQL




# Paramos MariaDB temporal
mysqladmin -uroot -p"${ROOT_PASSWORD}" shutdown

# Arrancamos en primer plano (modo contenedor)
echo ">> MariaDB iniciado correctamente, listo para recibir conexiones."
exec mysqld_safe
