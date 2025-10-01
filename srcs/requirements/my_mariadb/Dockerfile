FROM debian:oldstable

# Install MariaDB and utilities
RUN apt-get update && \
    apt-get install -y mariadb-server mariadb-client procps && \
    rm -rf /var/lib/apt/lists/*

# Copy the configuration and script to the virtual machine
COPY ./conf/my_mariadb.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/makefile.sh /usr/local/bin/makefile.sh

# Grant execution permissions
RUN chmod +x /usr/local/bin/makefile.sh

# Expose the MariaDB port
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/makefile.sh"]
