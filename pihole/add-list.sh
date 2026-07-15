#!/usr/bin/env bash

# 1. Asegúrate de estar en la carpeta del pihole en el VPS
cd ~/docker/pihole

# 2. Verificar si sqlite3 está instalado en Arch, si no, instalarlo
if ! command -v sqlite3 &> /dev/null; then
    echo "🔍 'sqlite3' no está instalado. Instalando mediante pacman..."
    sudo pacman -Sy --noconfirm sqlite
else
    echo "✅ 'sqlite3' ya está instalado en el sistema."
fi

# 3. Leer el archivo adlists.txt e insertar cada URL en la base de datos local
echo "📥 Importando URLs de adlists.txt a Pi-hole..."
while read -r url; do
  # Ignora líneas vacías o comentarios que empiecen con #
  [[ -z "$url" || "$url" =~ ^# ]] && continue
  
  # Inserta en la base de datos local
  sqlite3 etc-pihole/gravity.db "INSERT OR IGNORE INTO adlist (address, enabled) VALUES ('$url', 1);"
done < adlists.txt

# 4. Dile a Pi-hole que descargue las nuevas listas de inmediato
echo "🔄 Actualizando la gravedad de Pi-hole (esto puede tardar un momento)..."
docker compose exec pihole pihole -g

echo "🎉 ¡Restauración completada con éxito en tu VPS Arch!"