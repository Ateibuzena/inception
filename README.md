# Inception Project - 42 Málaga

This project deploys a **complete WordPress stack** using **Docker Compose**, including **Nginx, PHP-FPM, and MariaDB**, with persistent volumes and secret management for the database.  

---

## 📦 Services

### 1. **my_nginx**
- **Image:** `my_nginx`
- **Container:** `my_nginx`
- **Ports:**
  - `443` → HTTPS inside the VM
  - `8080` → HTTP from host/VM (optional)
- **Volumes:**
  - `wp-data:/var/www/` → PHP/WordPress files path
- **Dependencies:** `my_php`
- **Restart:** `on-failure`
- **Network:** `my_network`

### 2. **my_php**
- **Image:** `my_php`
- **Container:** `my_php`
- **Port:**
  - `9000` → PHP-FPM
- **Environment file:** `.env`
- **Volumes:**
  - `wp-data:/var/www/`
- **Dependencies:** `my_mariadb`
- **Restart:** `on-failure`
- **Network:** `my_network`

### 3. **my_mariadb**
- **Image:** `my_mariadb`
- **Container:** `my_mariadb`
- **Port:**
  - `3306` → MariaDB
- **Environment variables:**
  - `MARIADB_DATABASE=my_wordpressdb`
  - `MARIADB_USER=wp_user`
  - `MARIADB_PASSWORD_FILE=/run/secrets/db_password`
  - `MARIADB_ROOT_PASSWORD_FILE=/run/secrets/db_root_password`
- **Secrets:**
  - `db_password`
  - `db_root_password`
- **Volumes:**
  - `db-data:/var/lib/mysql`
- **Restart:** `on-failure`
- **Network:** `my_network`

---

## 🔒 Secrets

- `db_root_password` → file: `../secrets/db_root_password.txt`
- `db_password` → file: `../secrets/db_password.txt`

> **Note:** Make sure the secret files exist and contain the passwords before starting the containers.

---

## 💾 Volumes

- `wp-data` → WordPress and PHP files
- `db-data` → persistent MariaDB data

---

## 🌐 Networks

- `my_network` → private network for project containers

---

## 🚀 Useful Commands

Start the stack:
```bash
docker compose -f srcs/docker-compose.yml up -d
```

Stop the containers:
```bash
docker compose -f srcs/docker-compose.yml down
```
Rebuild images and start everything from scratch:
```bash
docker compose -f srcs/docker-compose.yml build
docker compose -f srcs/docker-compose.yml up -d
```
## ✨ Tips

Keep secrets out of the repository.

Ensure volume permissions are correct (chmod 755 or chown as needed).

For debugging, use docker logs <container_name>.

## 🔧 Project Structure

srcs/
├─ docker-compose.yml
├─ requirements/
│  ├─ my_nginx/
│  ├─ my_php/
│  └─ my_mariadb/
secrets/
├─ db_password.txt
└─ db_root_password.txt
