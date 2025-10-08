# Makefile para Inception - limpio, eficiente y friendly

COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/azubieta/data
VOLUMES = my_mariadb my_php

# ---------------------------
# Regla principal: build + up
all: prepare build up

# ---------------------------
# Crear carpetas de volúmenes si no existen
prepare:
	@echo "📂 Creating data folders if missing..."
	@mkdir -p $(DATA_DIR)
	@for vol in $(VOLUMES); do \
		mkdir -p $(DATA_DIR)/$$vol; \
	done

# ---------------------------
# Construir todas las imágenes con docker-compose
build:
	@echo "🐳 Building all images..."
	@$(COMPOSE) build

# ---------------------------
# Levantar contenedores
up:
	@echo "🐳 Lifting containers..."
	@$(COMPOSE) up -d

# ---------------------------
# Bajar contenedores
down:
	@echo "🐳 Shutting down containers..."
	@$(COMPOSE) down

# ---------------------------
clean:
	@echo "🐳 Cleaning containers, volumes, networks, and data..."
	-@docker stop $$(docker ps -aq) 2>/dev/null || echo "❎ No containers running."
	-@docker rm -f $$(docker ps -aq) 2>/dev/null || echo "❎ No containers to remove."
	-@docker volume rm mariadb_data php_data 2>/dev/null || echo "❎ No volumes to remove."
	-@docker network rm $$(docker network ls -q | grep -vE "bridge|host|none") 2>/dev/null || echo "❎ No custom networks."
	-@rm -rf $(DATA_DIR)

# ---------------------------
# Eliminar absolutamente todo (imágenes, contenedores, volúmenes)
fclean: clean
	@echo "⚠️ Deleting all images..."
	-@docker rmi -f $$(docker images -q) 2>/dev/null || echo "❎ No images to delete."
	-@docker system prune -af --volumes

# ---------------------------
# Reconstruir y levantar todo desde cero
re: fclean all

# ---------------------------
# Reiniciar contenedores sin reconstruir
refresh:
	@echo "🐳 Restarting containers..."
	@if [ -n "$$(docker ps -q)" ]; then \
		docker restart $$(docker ps -q); \
	else \
		echo "❎ No containers running to restart."; \
	fi

.PHONY: all prepare build up down clean fclean re refresh
