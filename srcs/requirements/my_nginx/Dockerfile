# Usar Debian oldstable como base
FROM debian:oldstable

# Instalar Nginx y OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Crear directorio para certificados SSL y generar certificado autofirmado
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=ES/ST=Malaga/L=Malaga/O=42Malaga/OU=Student/CN=localhost"

# Ajustar permisos de la carpeta web
RUN chown -R www-data /var/www/ && \
    chmod -R 755 /var/www/

# Copiar archivo de configuración personalizado de Nginx
COPY conf/my_nginx.conf /etc/nginx/nginx.conf

# Configurar TLS y logs en el sitio por defecto
RUN sed -i 's|listen 80 default_server;|listen 80 default_server;\n    listen 443 ssl default_server;|' /etc/nginx/sites-available/default && \
    sed -i 's|listen \[::\]:80 default_server;|listen [::]:80 default_server;\n    listen [::]:443 ssl default_server;|' /etc/nginx/sites-available/default && \
    sed -i 's|# SSL configuration|ssl_certificate /etc/nginx/ssl/nginx.crt;\n    ssl_certificate_key /etc/nginx/ssl/nginx.key;\n    ssl_protocols TLSv1.2 TLSv1.3;|' /etc/nginx/sites-available/default

# Exponer puertos HTTP y HTTPS
EXPOSE 80 443

# Ejecutar Nginx en primer plano
CMD ["nginx", "-g", "daemon off;"]
