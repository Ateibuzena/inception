# Makefile for Inception - clean, efficient, and friendly

COMPOSE = docker compose -f srcs/docker-compose.yml
DATA_DIR = /home/azubieta/data
VOLUMES = my_mariadb my_php

# ---------------------------
# Main rule: build + up
all: prepare build up

# ---------------------------
# Create volume folders if they don't exist
prepare:
	@echo "📂 Creating data folders if missing..."
	@mkdir -p $(DATA_DIR)
	@for vol in $(VOLUMES); do \
		mkdir -p $(DATA_DIR)/$$vol; \
	done

# ---------------------------
# Build all images with docker-compose
build:
	@echo "🐳 Building all images..."
	@$(COMPOSE) build

# ---------------------------
# Start containers
up:
	@echo "🐳 Lifting containers..."
	@$(COMPOSE) up -d

# ---------------------------
# Stop containers
down:
	@echo "🐳 Shutting down containers..."
	@$(COMPOSE) down

# ---------------------------
# Clean containers, volumes, networks, and data
clean:
	@echo "🐳 Cleaning containers, volumes, networks, and data..."
	-@docker stop $$(docker ps -aq) 2>/dev/null || echo "❎ No containers running."
	-@docker rm -f $$(docker ps -aq) 2>/dev/null || echo "❎ No containers to remove."
	-@docker volume rm mariadb_data php_data 2>/dev/null || echo "❎ No volumes to remove."
	-@docker network rm $$(docker network ls -q | grep -vE "bridge|host|none") 2>/dev/null || echo "❎ No custom networks."
	-@rm -rf $(DATA_DIR)

# ---------------------------
# Remove absolutely everything (images, containers, volumes)
fclean: clean
	@echo "⚠️ Deleting all images..."
	-@docker rmi -f $$(docker images -q) 2>/dev/null || echo "❎ No images to delete."
	-@docker system prune -af --volumes

# ---------------------------
# Rebuild and lift everything from scratch
re: fclean all

# ---------------------------
# Restart containers without rebuilding
refresh:
	@echo "🐳 Restarting containers..."
	@if [ -n "$$(docker ps -q)" ]; then \
		docker restart $$(docker ps -q); \
	else \
		echo "❎ No containers running to restart."; \
	fi

.PHONY: all prepare build up down clean fclean re refresh
