#!/bin/bash

# Actualizar e instalar paquetes necesarios
if sudo apt update; then
    echo "Actualización exitosa."
else
    echo "Error durante la actualización. Por favor, verifica y corrige los errores."
    exit 1
fi

if sudo apt install -y ca-certificates curl gnupg; then
    echo "Instalación exitosa de paquetes necesarios."
else
    echo "Error durante la instalación de paquetes necesarios. Por favor, verifica y corrige los errores."
    exit 1
fi

# Crear directorio para las claves GPG si no existe
if sudo install -m 0755 -d /etc/apt/keyrings; then
    echo "Directorio creado exitosamente."
else
    echo "Error al crear el directorio. Por favor, verifica y corrige los errores."
    exit 1
fi

# Descargar el archivo GPG de Docker solo si no existe
GPG_FILE="/etc/apt/keyrings/docker.gpg"
if [ ! -f "$GPG_FILE" ]; then
    if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "$GPG_FILE" && sudo chmod a+r "$GPG_FILE"; then
        echo "Descarga y configuración de la clave GPG exitosa."
    else
        echo "Error durante la descarga y configuración de la clave GPG. Por favor, verifica y corrige los errores."
        exit 1
    fi
else
    echo "El archivo $GPG_FILE ya existe. Saltando la descarga."
fi

# Agregar el repositorio de Docker al archivo sources.list
DOCKER_REPO="https://download.docker.com/linux/ubuntu"
if echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] $DOCKER_REPO $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null; then
    echo "Repositorio de Docker agregado exitosamente."
else
    echo "Error al agregar el repositorio de Docker. Por favor, verifica y corrige los errores."
    exit 1
fi

# Actualizar e instalar Docker
if sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    echo "Docker se ha instalado correctamente."
else
    echo "Hubo un problema durante la instalación de Docker. Por favor, verifica y corrige los errores."
    exit 1
fi

# Eliminar carpeta odoo
if rm -rf odoo/; then
    echo "Se eliminó la carpeta Odoo"
else
    echo "Hubo un problema para eliminar la carpeta odoo"
    exit 1
fi
