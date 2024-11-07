# ansible
Ansible tutorial repo files

#docker system prune -a --volumes

cd .devcontainer
docker compose build --no-cache --pull --progress plain
docker compose -f docker-compose.yml up --detach --remove-orphans
docker system prune --volumes -f

#

docker compose -f docker-compose.yml down --remove-orphans vault
docker compose build --no-cache --pull --progress plain vault
docker compose -f docker-compose.yml up --detach --remove-orphans vault

#

docker exec -it vault-container /bin/ash