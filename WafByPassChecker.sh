#!/bin/bash
#  Autor: Omar Peña
# Descripción: Herramienta de edentificación de posibles WAF Bypass.
# Repo: https://github.com/Macle0d/WafBypassChecker
# Version: 1.0
# ============================================================
# CONFIGURACIONES Y VARIABLES GLOBALES
# ============================================================
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
TIMEOUT=10
URL=""
IP=""
FILE=""

# ============================================================
# FUNCIONES
# ============================================================
usage() {
  # Opcional: colores para resaltar (si lo deseas)
  GRN="\e[32m"   # Verde
  BLD="\e[1m"    # Negrita
  RST="\e[0m"    # Reset

  echo -e "\n${BLD}Uso:${RST}"
  echo -e "  $0 -u <URL> [opciones]"
  echo -e "  -u, --url <URL>        Especifica la URL del sitio objetivo."
  echo -e "  -ip, --ip <IP>         Direccion IP real del sitio."
  echo -e "  -f, --file <archivo>   Archivo con una lista de IPs (una por línea)."
  echo
  echo -e "${BLD}Ejemplos de uso:${RST}"
  echo "  $0 -u \"https://www.ejemplo.com\" -ip 1.2.3.4"
  echo "  $0 -u \"https://www.ejemplo.com\" -f ips.txt"
  echo
  echo -e "${BLD}Prueba Manual (bypass con /etc/hosts):${RST}"
  echo "  1. Editar el archivo /etc/hosts:"
  echo "       sudo nano /etc/hosts"
  echo
  echo "  2. Agregar la IP y dominio al final, por ejemplo:"
  echo "       1.2.3.4 www.ejemplo.com"
  echo
  echo "  3. Ejecutar wafw00f para verificar si el WAF protege el sitio accedido por su IP real:"
  echo "       wafw00f https://www.ejemplo.com"
  echo
  exit 1
}


check_ip() {
  local TEST_IP=$1
  echo -n -e " \e[1m\e[38;5;202m➡\e[0m Probando con la IP: \e[1m\e[38;5;11m$TEST_IP\e[0m"
  RESPONSE_TITLE=$(curl -sk -L -A "$USER_AGENT" --max-time "$TIMEOUT" \
    --resolve "$(echo $URL | awk -F/ '{print $3}'):443:$TEST_IP" "$URL" \
    | grep -oP '(?i)(?<=>).*?(?=</title>)')

  if [[ "$RESPONSE_TITLE" == "$ORIGINAL_TITLE" ]]; then
    echo -e " \e[31m\e[38;5;1m\e[1m✘ ¡Posible WAF Bypass detectado!\e[0m"
    echo -e "\n Payload: \e[1m\e[94mcurl \e[38;5;172m-sk -L --max-time \e[97m\"\e[1m\e[38;5;11m$TIMEOUT\e[97m\" \e[38;5;172m--resolve\e[97m \"\e[1m\e[38;5;11m$(echo $URL | awk -F/ '{print $3}')\e[97m\":443:$TEST_IP $URL\e[0m\n"
  else
    echo -e " \e[32m\e[38;5;82m\e[1m✔\e[39m\e[0m No WAF Bypass Detected...\e[0m"
  fi
}

# ============================================================
# VALIDACIÓN DE PARÁMETROS
# ============================================================
[[ $# -lt 3 ]] && usage

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -u)
      URL="$2"
      shift 2
      ;;
    -ip)
      [[ -n "$FILE" ]] && { echo "Error: No puede usar -ip y -f al mismo tiempo."; exit 1; }
      IP="$2"
      shift 2
      ;;
    -f)
      [[ -n "$IP" ]] && { echo "Error: No puede usar -ip y -f al mismo tiempo."; exit 1; }
      FILE="$2"
      shift 2
      ;;
    *)
      usage
      ;;
  esac
done

# Validar URL
if ! [[ "$URL" =~ ^https?:\/\/[a-zA-Z0-9.-]+(:[0-9]+)?(\/.*)?$ ]]; then
  echo "Error: La URL proporcionada no es válida."
  exit 1
fi

# ============================================================
# BANNER
# ============================================================
echo -e "\e[38;5;82m                                                                  "
echo -e "\e[38;5;82m █░█░█ ▄▀█ █▀▀ \e[38;5;172m █▄▄ █▄█ █▀█ ▄▀█ █▀ █▀ \e[38;5;82m █▀▀ █░█ █▀▀ █▀▀ █▄▀ █▀▀ █▀█ \e[0m"
echo -e "\e[38;5;82m ▀▄▀▄▀ █▀█ █▀░ \e[38;5;172m █▄█ ░█░ █▀▀ █▀█ ▄█ ▄█ \e[38;5;82m █▄▄ █▀█ ██▄ █▄▄ █░█ ██▄ █▀▄ \e[0m"
echo -e "\e[38;5;82m                                       \e[1mVersion 1.0 - By @p3nt3ster \e[0m"
echo -e "\n═════════════════════════════════════════════════"
echo -e " URL a comprobar: \e[38;5;87m\e[1m$URL\e[0m"

# ============================================================
# OBTENER TÍTULO ORIGINAL
# ============================================================
ORIGINAL_TITLE=$(curl -sk -L -A "$USER_AGENT" --max-time "$TIMEOUT" "$URL" \
  | grep -oP '(?i)(?<=>).*?(?=</title>)')

if [[ -z "$ORIGINAL_TITLE" ]]; then
  echo -e " Error: No se pudo obtener el título del HTML original de la URL."
  exit 1
fi
echo -e " Título original: $ORIGINAL_TITLE"

# ============================================================
# DETECTAR WAF MEDIANTE WAFW00F
# ============================================================
OUTPUT=$(wafw00f "$URL" 2>/dev/null)
if echo "$OUTPUT" | grep -q "No WAF detected"; then
  echo -e " \e[31m\e[38;5;1m\e[1m⛔ ¡No se ha identificado una protección WAF en el sitio...!\e[0m"
  exit 0
else
  WAF_NAME=$(echo "$OUTPUT" | grep -oP '(?<=is behind ).*(?= WAF\.)')
  if [[ -n "$WAF_NAME" ]]; then
    echo -e "   WAF detectado: $WAF_NAME"
  else
    echo -e " WAF detectado, pero no se pudo determinar el nombre!"
  fi
fi
echo -e "═════════════════════════════════════════════════"

# ============================================================
# PROCESAR IP O ARCHIVO
# ============================================================
if [[ -n "$IP" ]]; then
  check_ip "$IP"
elif [[ -n "$FILE" ]]; then
  [[ ! -f "$FILE" ]] && { echo -e " Error: El archivo $FILE no existe."; exit 1; }
  while IFS= read -r line; do
    check_ip "$line"
  done < "$FILE"
else
  echo -e " Error: Debe proporcionar una IP (-ip) o un archivo (-f)."
  exit 1
fi