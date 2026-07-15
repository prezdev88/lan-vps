#!/usr/bin/env bash

cd ~/docker/pihole

# 1. Verificar sqlite3
if ! command -v sqlite3 &> /dev/null; then
    echo "🔍 'sqlite3' no está instalado. Instalando mediante pacman..."
    sudo pacman -Sy --noconfirm sqlite
else
    echo "✅ 'sqlite3' ya está instalado en el sistema."
fi

# 2. Comprobar si hubo cambios en adlists.txt usando md5sum
HASH_FILE=".adlists.hash"
NUEVO_HASH=$(md5sum adlists.txt 2>/dev/null)

if [ -f "$HASH_FILE" ] && [ "$NUEVO_HASH" = "$(cat $HASH_FILE)" ]; then
    echo "✨ No hay cambios en adlists.txt. Tu Pi-hole ya está al día. ¡Nada que hacer!"
    exit 0
fi

# 3. Importar URLs si hay cambios
echo "📥 Importando URLs de adlists.txt a Pi-hole..."
while read -r url; do
  [[ -z "$url" || "$url" =~ ^# ]] && continue
  sqlite3 etc-pihole/gravity.db "INSERT OR IGNORE INTO adlist (address, enabled) VALUES ('$url', 1);"
done < adlists.txt

# 4. Actualizar solo si el proceso completó correctamente
echo "🔄 Actualizando la gravedad de Pi-hole (esto puede tardar un momento)..."
if docker compose exec pihole pihole -g; then
    # Guardar el nuevo hash para la próxima vez
    echo "$NUEVO_HASH" > "$HASH_FILE"
    echo "🎉 ¡Restauración y actualización completadas con éxito!"
else
    echo "❌ Error al actualizar la gravedad en el contenedor de Pi-hole."
fi
