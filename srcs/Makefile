# Makefile para Inception - manejo de imágenes locales y contenedores

COMPOSE = docker-compose
IMAGES_DIR = ./images

# Nombres de imágenes locales
PHP_IMAGE = my_php
MARIADB_IMAGE = my_mariadb
NGINX_IMAGE = my_nginx

# ---------------------------
# Regla principal: limpiar + build + up
all: clean load-or-build-images
	@echo "🟢 Levantando contenedores..."
	@$(COMPOSE) up -d --no-build

# ---------------------------
# Cargar o construir imágenes
load-or-build-images: $(IMAGES_DIR)
	@echo "🟢 Procesando imágenes locales..."
	@$(call load_or_build,$(PHP_IMAGE),./requirements/my_php)
	@$(call load_or_build,$(MARIADB_IMAGE),./requirements/my_mariadb)
	@$(call load_or_build,$(NGINX_IMAGE),./requirements/my_nginx)

define load_or_build
	@mkdir -p $(IMAGES_DIR)
	if [ -f $(IMAGES_DIR)/$1.tar ]; then \
		echo "	📦 Cargando imagen local $1..."; \
		docker load -i $(IMAGES_DIR)/$1.tar; \
	else \
		echo "	✨ Construyendo imagen $1..."; \
		docker build --no-cache -t $1 $2 && \
		( echo "💾 Guardando imagen $1 en $(IMAGES_DIR)/$1.tar"; \
		  docker save -o $(IMAGES_DIR)/$1.tar $1 ); \
	fi
endef

# ---------------------------
# Limpieza parcial (contenedores, volúmenes, redes)
clean:
	@echo "🟢 Limpiando imágenes locales (imágenes guardadas intactas)..."
	-@docker rmi -f $$(docker images -q) 2>/dev/null || echo "	⚠️ No hay imágenes para eliminar."
	@echo "🟢 Limpiando contenedores (imágenes guardadas intactas)..."
	-@docker stop $$(docker ps -aq) 2>/dev/null || echo "	⚠️ No hay contenedores ejecutándose."
	-@docker rm -f $$(docker ps -aq) 2>/dev/null || echo "	⚠️ No hay contenedores para eliminar."
	@echo "🟢 Limpiando volúmenes (imágenes guardadas intactas)..."
	-@docker volume rm $$(docker volume ls -q) 2>/dev/null || echo "	⚠️ No hay volúmenes para eliminar."
	@echo "🟢 Limpiando redes (imágenes guardadas intactas)..."
	-@docker network rm $$(docker network ls -q | grep -vE "bridge|host|none") 2>/dev/null || echo "	⚠️ No hay redes personalizadas."

# ---------------------------
# Limpieza total
fclean: clean
	@echo "🛑 Eliminando absolutamente todo (incluyendo imágenes locales)..."
	-@docker rmi -f $$(docker images -q) 2>/dev/null || echo "	⚠️ No hay imágenes locales para eliminar."
	-@rm -rf $(IMAGES_DIR) || echo "	⚠️ No hay images guardadas para eliminar."
	-@docker system prune -af --volumes

up:
	@echo "🟢 Levantando contenedores..."
	@$(COMPOSE) up -d

# ---------------------------
# Bajar contenedores
down:
	@echo "🟢 Apagando contenedores..."
	@$(COMPOSE) down

# ---------------------------
# Rehacer todo desde cero
re: fclean all

# ---------------------------
# Refresh: limpiar contenedores/volúmenes pero mantener imágenes
refresh: clean load-or-build-images up

.PHONY: all clean fclean up down re load-or-build-images refresh images
