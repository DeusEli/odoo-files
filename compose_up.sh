#!/bin/bash

# Crear archivo .env utilzar en el docker-compose.yml
ENV_FILE=".env"
declare -A variables=(
    ["CUSTOMER"]=$1
    ["ODOO_VERSION"]=$2
    ["ODOO_PORT"]=$3
    ["LABEL"]=$4
    ["ODOO_CONTAINER"]=$1_odoo$2_$4
)
for variable in "${!variables[@]}"; do
  echo "$variable=${variables[$variable]}" >> "$ENV_FILE"
done

# Ejecución del script para crear el archivo docker-compose.yml en base a las variables de entorno
chmod +x ./env_substitution_on_files.sh && ./env_substitution_on_files.sh

# Levantar los contenedores
if docker compose up -d; then
    echo "Contenedores levantados exitosamente"
else
    echo "Error al levantar los contenedores. Detalles del error: $?"
    exit 1  # Termina el script con un código de salida no exitoso
fi

# Cambiar los permisos de la carpeta /var/lib/odoo
CUSTOMER=$1
ODOO_VERSION=$2
LABEL=$4
CONTAINER_NAME="${CUSTOMER}_odoo${ODOO_VERSION}_${LABEL}"
if exec_result=$(docker exec -u root ${CONTAINER_NAME} chown -R odoo:odoo /var/lib/odoo 2>&1); then
    echo "Cambio de permisos exitoso"
else
    echo "Error al cambiar los permisos. Detalles del error: $exec_result"
fi
