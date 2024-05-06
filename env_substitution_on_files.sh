#!/bin/bash

# Cargar variables de entorno desde el archivo .env
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Verificar si se proporcionan todas las variables requeridas
if [ -z "$CUSTOMER" ] || [ -z "$ODOO_VERSION" ] || [ -z "$ODOO_PORT" ] || [ -z "$LABEL" ] || [ -z "$ODOO_CONTAINER" ]; then
    echo "Falta una o más variables de entorno requeridas en el archivo .env"
    exit 1
fi

# Generar docker-compose.yml reemplazando las variables del template
envsubst < docker-compose.template.yml > docker-compose.yml

# Generar nginx.config reemplazando las variables del template
envsubst '${ODOO_CONTAINER}' < conf/nginx.conf.template > conf/nginx.conf

echo "Archivo docker-compose.yml generado exitosamente."
