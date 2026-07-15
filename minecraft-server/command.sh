#!/usr/bin/env bash
set -euo pipefail

CONTAINER_NAME="${MC_CONTAINER_NAME:-minecraft-forge}"

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Falta comando: $1" >&2; exit 1; }
}

require docker

if ! docker ps --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
  echo "No encuentro el contenedor '${CONTAINER_NAME}' corriendo." >&2
  echo "Contenedores activos:" >&2
  docker ps --format ' - {{.Names}}'
  exit 1
fi

send_cmd() {
  local cmd="$1"
  docker exec -i "${CONTAINER_NAME}" rcon-cli "${cmd}"
}

# Modo no-interactivo: ./server-console.sh "say hola"
if [[ $# -gt 0 ]]; then
  send_cmd "$*"
  exit 0
fi

echo "Consola interactiva Minecraft (RCON) -> contenedor: ${CONTAINER_NAME}"
echo "Escribe comandos como en la consola del server. 'quit'/'exit' para salir."
echo

while true; do
  # Prompt "server> "
  printf "server> "
  IFS= read -r line || break

  # Trim simple
  line="${line#"${line%%[![:space:]]*}"}"
  line="${line%"${line##*[![:space:]]}"}"

  [[ -z "$line" ]] && continue
  [[ "$line" == "exit" || "$line" == "quit" ]] && break

  # Envía y muestra respuesta
  send_cmd "$line" || true
done