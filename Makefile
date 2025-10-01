# Makefile for Inception - handling local images and containers

COMPOSE = docker-compose -f srcs/docker-compose.yml
IMAGES_DIR = ./images
VOLUMES_DIR = /home/azubieta/data

# Local image names
PHP_IMAGE = my_php
MARIADB_IMAGE = my_mariadb
NGINX_IMAGE = my_nginx

# ---------------------------
# Main rule: limpiar + build + up
all: clean load-or-build-images
	@echo "🐳 Lifting containers..."
	@$(COMPOSE) up -d --no-build

# ---------------------------
# Upload or build images
load-or-build-images: $(IMAGES_DIR)
	@if [ ! -d $(VOLUMES_DIR) ]; then \
		echo "🐳 Creating folders for volumes in $(VOLUMES_DIR)..."; \
		mkdir -p $(VOLUMES_DIR)/my_mariadb; \
		mkdir -p $(VOLUMES_DIR)/my_php; \
	fi
	@echo "🐳 Processing local images..."
	@$(call load_or_build,$(PHP_IMAGE),./srcs/requirements/my_php)
	@$(call load_or_build,$(MARIADB_IMAGE),./srcs/requirements/my_mariadb)
	@$(call load_or_build,$(NGINX_IMAGE),./srcs/requirements/my_nginx)

define load_or_build
	@mkdir -p $(IMAGES_DIR)
	if [ -f $(IMAGES_DIR)/$1.tar ]; then \
		echo "	📦 Loading local image $1..."; \
		docker load -i $(IMAGES_DIR)/$1.tar; \
	else \
		echo "	✨ Building image $1..."; \
		docker build --no-cache -t $1 $2 && \
		( echo "💾 Saving image $1 en $(IMAGES_DIR)/$1.tar"; \
		  docker save -o $(IMAGES_DIR)/$1.tar $1 ); \
	fi
endef

# ---------------------------
# Partial cleaning (containers, volumes, networks)
clean:
	@echo "🐳 Cleaning up local images (saved images intact)..."
	-@docker rmi -f $$(docker images -q) 2>/dev/null || echo "	❎  No images to remove."
	@echo "🐳 Cleaning up containers (saved images intact)..."
	-@docker stop $$(docker ps -aq) 2>/dev/null || echo "	❎  No containers running."
	-@docker rm -f $$(docker ps -aq) 2>/dev/null || echo "	❎  No containers to remove."
	@echo "🐳 Cleaning up volumes (saved images intact)..."
	-@rm -rf $(VOLUMES_DIR) || echo "	❎  No saved volumes to remove."
	-@docker volume rm $$(docker volume ls -q) 2>/dev/null || echo "	❎  There are no volumes to delete."
	@echo "🐳 Cleaning networks (saved images intact)..."
	-@docker network rm $$(docker network ls -q | grep -vE "bridge|host|none") 2>/dev/null || echo "	❎  No custom networks."

# ---------------------------
# Total cleaning
fclean: clean
	@echo "⚠️ Delete absolutely everything (including local images)..."
	-@docker rmi -f $$(docker images -q) 2>/dev/null || echo "	❎  There are no local images to delete."
	-@rm -rf $(IMAGES_DIR) || echo "	❎  There are no saved images to delete."
	-@docker system prune -af --volumes

# ---------------------------
# Lifting containers
up:
	@echo "🐳 Lifting containers..."
	@$(COMPOSE) up -d

# ---------------------------
# Lower containers
down:
	@echo "🐳 Shutting down containers..."
	@$(COMPOSE) down

# ---------------------------
# Redo everything from scratch
re: fclean all

# ---------------------------
# Restart
refresh:
	@echo "🐳 Restarting containers..."
	@if [ -n "$$(docker ps -q)" ]; then \
		docker restart $$(docker ps -q); \
	else \
		echo "	❎  There are no containers running to restart."; \
	fi

.PHONY: all clean fclean up down re load-or-build-images refresh images
