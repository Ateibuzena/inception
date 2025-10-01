FROM debian:oldstable

# Install Nginx and OpenSSL
RUN apt-get update && \
    apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Create a directory for SSL certificates and generate a self-signed certificate
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
        -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx.key \
        -out /etc/nginx/ssl/nginx.crt \
        -subj "/C=ES/ST=Malaga/L=Malaga/O=42Malaga/OU=Student/CN=localhost"

# Adjust the web folder permissions
RUN chown -R www-data /var/www/ && \
    chmod -R 755 /var/www/

# Copy custom Nginx configuration file
COPY conf/my_nginx.conf /etc/nginx/nginx.conf

# Configure TLS and logs on the site by default
RUN sed -i 's|listen 80 default_server;|listen 80 default_server;\n    listen 443 ssl default_server;|' /etc/nginx/sites-available/default && \
    sed -i 's|listen \[::\]:80 default_server;|listen [::]:80 default_server;\n    listen [::]:443 ssl default_server;|' /etc/nginx/sites-available/default && \
    sed -i 's|# SSL configuration|ssl_certificate /etc/nginx/ssl/nginx.crt;\n    ssl_certificate_key /etc/nginx/ssl/nginx.key;\n    ssl_protocols TLSv1.2 TLSv1.3;|' /etc/nginx/sites-available/default

# Expose HTTP and HTTPS ports
EXPOSE 80 443

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
