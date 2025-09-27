# Makefile para gestionar entorno Docker Inception

# Variables
COMPOSE = docker-compose
PROJECT = inception

# Regla por defecto (si solo haces "make")
all: rebuild

# Limpieza total
clean:
	@echo "🟢 Desmontando todo..."
	-@docker stop $$(docker ps -aq) 2>/dev/null || echo "⚠️  No hay contenedores en ejecución."
	-@docker rm -f $$(docker ps -aq) 2>/dev/null || echo "⚠️  No hay contenedores para eliminar."
	-@docker rmi -f $$(docker images -aq) 2>/dev/null || echo "⚠️  No hay imágenes para eliminar."
	-@docker volume rm $$(docker volume ls -q) 2>/dev/null || echo "⚠️  No hay volúmenes para eliminar."
	-@docker network rm $$(docker network ls -q | grep -vE "bridge|host|none") 2>/dev/null || echo "⚠️  No hay redes personalizadas para eliminar."
	-@$(COMPOSE) down -v --rmi all --remove-orphans 2>/dev/null || echo "⚠️  Docker Compose no eliminó nada."
	-@docker system prune -af 2>/dev/null || echo "⚠️  System prune no eliminó nada."
	-@docker volume prune -f 2>/dev/null || echo "⚠️  Volume prune no eliminó nada."

# Construcción sin caché
build:
	@echo "🟢 Construyendo imagen..."
	@$(COMPOSE) build --no-cache

# Levantar servicios
up:
	@echo "🟢 Levantando contenedor..."
	@$(COMPOSE) -p $(PROJECT) up -d

# Atajo: limpiar + build + up
rebuild: clean build up

# Bajar servicios
down:
	@echo "🟢 Apagando contenedor..."
	@$(COMPOSE) -p $(PROJECT) down

.PHONY: all clean build up rebuild down
