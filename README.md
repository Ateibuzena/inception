# Proyecto Inception - Docker + WordPress + MariaDB + Nginx + PHP

Este proyecto contiene una **instalación de WordPress** con **PHP-FPM**, **MariaDB** y **Nginx**, gestionado mediante **Docker Compose**. Incluye scripts de inicialización y buenas prácticas para manejar secretos, imágenes locales y builds rápidos.

---

## 📁 Estructura del proyecto

```text
inception/
├── README.md
├── .gitignore
├── secrets/
│   ├── db_password.txt
│   └── db_root_password.txt
└── srcs/
    ├── docker-compose.yml
    ├── Makefile
    ├── images/
    │   ├── my_mariadb.tar
    │   ├── my_nginx.tar
    │   └── my_php.tar
    └── requirements/
        ├── my_mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── my_mariadb.cnf
        │   └── tools/
        │       └── makefile.sh
        ├── my_nginx/
        │   ├── Dockerfile
        │   └── conf/
        │       └── my_nginx.conf
        └── my_php/
            ├── Dockerfile
            └── tools/
                └── makefile.sh
```

## 📝 .gitignore del proyecto

Colocado en la raíz (inception/.gitignore):

```bash
# Docker images exportadas
srcs/images/*.tar

# Secrets
secrets/*.txt

# Archivos temporales del sistema
*.swp
*.tmp
*.bak
*.DS_Store

# Logs
*.log
```

Esto evita subir secretos, imágenes y archivos temporales al repositorio.

## 📄 .dockerignore por servicio

Cada servicio tiene su .dockerignore en el mismo directorio que el Dockerfile, para que Docker no copie archivos innecesarios al build.

### requirements/my_php/.dockerignore

```bash
../../images/*.tar
*.log
*.tmp
*.swp
../../../secrets/*.txt
.vscode/
.idea/
```

### requirements/my_nginx/.dockerignore

```bash
*.log
*.tmp
*.swp
../../../secrets/*.txt
.vscode/
.idea/
```

### requirements/my_mariadb/.dockerignore

```bash
*.log
*.tmp
*.swp
../../../secrets/*.txt
.vscode/
.idea/
```

Ajusta las rutas relativas según la ubicación del Dockerfile.

## ⚙️ Uso del Makefile

El Makefile facilita la gestión de contenedores, imágenes y limpieza de recursos.

```text
Comandos principales:   Comando	Descripción:
make all	            Limpia contenedores/volúmenes/redes, build de imágenes y levanta contenedores
make clean	            Limpia contenedores, volúmenes y redes, pero mantiene imágenes
make fclean	            Limpieza total, incluyendo imágenes y carpeta images
make up	                Levanta los contenedores sin hacer build
make down	            Apaga los contenedores
make refresh	        Limpia contenedores/volúmenes y rebuild de imágenes
```

Nota: load-or-build-images se encarga de cargar imágenes locales si existen, o construirlas y guardarlas en srcs/images/*.tar.

## 💻 Docker Compose

El archivo docker-compose.yml define tres servicios:

- my_php:

    Contiene PHP-FPM y WordPress CLI

    Monta volumen wp-data:/var/www

    Depende de my_mariadb

- my_nginx:

    Servidor Nginx

    Monta el mismo volumen wp-data que PHP

    Expone puertos 80 y 443

- my_mariadb:

    Contiene la base de datos MariaDB

    Usa secretos para contraseña

    Monta volumen db-data:/var/lib/mysql

```bash
Volúmenes y redes
volumes:
  wp-data:
    name: wp-data
    driver: local
  db-data:
    name: db-data
    driver: local

networks:
  my_network:
```

## 🔐 Manejo de secretos

Archivos .txt en secrets/ contienen las contraseñas de MariaDB.

Nunca se suben a Git, ni se copian a la imagen (.gitignore y .dockerignore).

### ⚡ Recomendaciones para builds rápidos

Usar .dockerignore para evitar copiar imágenes, logs y secretos al build.

Guardar imágenes construidas en srcs/images/*.tar para reutilización.

Evitar instalar WordPress automáticamente antes de que la DB esté lista; usar wait loops en scripts de PHP.

## 🛠️ Limpieza de la VM

- Limpiar contenedores y redes:

docker stop $(docker ps -aq)
docker rm -f $(docker ps -aq)
docker network rm $(docker network ls -q | grep -vE "bridge|host|none")
docker system prune -af --volumes


- Limpiar logs del sistema:

sudo journalctl --vacuum-size=100M
sudo rm -rf /var/log/*.log.*


- Limpiar cache de memoria (opcional):

sudo sync; sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'

## 🚀 Iniciar el proyecto

Desde la raíz del proyecto (inception/):

```bash
cd srcs
make all
```

Esto limpiará, construirá las imágenes y levantará los contenedores.

Luego puedes acceder a WordPress en:

```text
http://<IP_VM>:8080
https://<IP_VM>:443
```

Este README ya incluye estructura, manejo de secretos, .gitignore, .dockerignore, Makefile y limpieza de VM.