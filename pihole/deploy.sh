#!/usr/bin/env bash

# 1. Asegúrate de estar en la carpeta del pihole
cd "$(dirname "$0")"

# 2. Levanta el contenedor de Pi-hole en segundo plano
echo "🚀 Levantando el contenedor de Pi-hole..."
docker compose up -d

# 3. Espera unos segundos a que Pi-hole cree la base de datos inicial si es la primera vez
echo "⏳ Esperando a que el servicio se estabilice..."
sleep 10

# 4. Ejecuta tu script de restauración de adlists
if [ -f "./ad-list.sh" ]; then
    echo "⚙️ Ejecutando restauración de adlists..."
    chmod +x ad-list.sh
    ./ad-list.sh
else
    echo "⚠️ No se encontró el archivo ad-list.sh en esta carpeta."
fi