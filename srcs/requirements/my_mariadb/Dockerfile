FROM debian:oldstable

# Instalamos mariadb y utilidades
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client procps && \
    rm -rf /var/lib/apt/lists/*

# Copiamos config y script en la vm
COPY ./conf/my_mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/makefile.sh /usr/local/bin/makefile.sh

# Damos permisos de ejecución
RUN chmod +x /usr/local/bin/makefile.sh

# Exponemos puerto de MariaDB
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/makefile.sh"]
