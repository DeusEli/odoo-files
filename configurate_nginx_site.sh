#!/bin/bash

# Función para configurar un sitio virtual en Nginx
configure_site() {
    DOMAIN=$1
    PORT=$2

cat <<EOF >"/etc/nginx/sites-available/$DOMAIN"
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

    ln -s /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
}

# Verificar si el script se está ejecutando como root
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ser ejecutado como root."
    exit 1
fi

# Verificar que se proporcionen los argumentos necesarios
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <dominio> <puerto>"
    exit 1
fi

DOMAIN=$1
PORT=$2

# Verificar si el sitio virtual ya está configurado
if [ -e "/etc/nginx/sites-available/$DOMAIN" ]; then
    echo "El sitio virtual $DOMAIN ya está configurado."
    exit 1
fi

# Configurar el sitio virtual
configure_site $DOMAIN $PORT

# Reiniciar Nginx
systemctl restart nginx

echo "El sitio virtual $DOMAIN ha sido configurado correctamente."
