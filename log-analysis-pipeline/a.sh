#!/bin/bash

# Verificamos si se proporcionó una URL como parámetro
if [ -z "$1" ]; then
  # Si no se proporciona un parámetro, mostrar el uso correcto y salir con código de error 1
  echo "Uso: $0 <URL_del_archivo_ZIP>"
  exit 1
fi

# URL del archivo ZIP proporcionado como parámetro
ZIP_URL="$1"
# Nombre del archivo ZIP a guardar localmente
ZIP_FILE="logs.zip"

# Función para descargar el archivo desde Google Drive
download_from_gdrive() {
  # Extrae el ID del archivo de la URL
  FILE_ID=$(echo "$1" | grep -o 'd/.*' | cut -d'/' -f2)
  # Obtener el código de confirmación necesario para descargar el archivo
  CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://drive.google.com/uc?export=download&id=${FILE_ID}" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
  # Descarga el archivo usando el código de confirmación
  wget --quiet --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILE_ID}" -O "$2"
  # Elimina las cookies temporales
  rm -rf /tmp/cookies.txt
}

# Descargamos el archivo ZIP desde Google Drive
download_from_gdrive "$ZIP_URL" "$ZIP_FILE"

# Extraemos el contenido del archivo ZIP en el directorio actual, suprimiendo la salida
unzip -o $ZIP_FILE > /dev/null 2>&1

# Función para procesar el archivo android.log
process_android_log() {
  local LOG_FILE=$1
  local INDEX=$2
  # Calcula el hash MD5 del archivo
  MD5=$(md5sum "$LOG_FILE" | cut -d' ' -f1)
  # Cuenta el número total de líneas en el archivo
  TOTAL_LINES=$(wc -l < "$LOG_FILE")
  # Obtiene el nombre del archivo sin la extensión .log
  FILENAME=$(basename "$LOG_FILE" .log)
  
  # Obtiene la primera y última línea del archivo
  FIRST_RECORD=$(head -n 1 "$LOG_FILE")
  LAST_RECORD=$(tail -n 1 "$LOG_FILE")
  
  # Extraemos la fecha y hora del primer y último registro
  DATE_FIRST=$(echo $FIRST_RECORD | cut -d' ' -f1)
  TIME_FIRST=$(echo $FIRST_RECORD | cut -d' ' -f2)
  DATE_LAST=$(echo $LAST_RECORD | cut -d' ' -f1)
  TIME_LAST=$(echo $LAST_RECORD | cut -d' ' -f2)

  # Imprimimos los resultados
  echo "MD5: $MD5"
  echo "Total Number of Lines: $TOTAL_LINES"
  echo "Filename_$INDEX: $FILENAME"
  echo "Date of First Record: $DATE_FIRST"
  echo "Time of First Record: $TIME_FIRST"
  echo "Date of Last Record: $DATE_LAST"
  echo "Time of Last Record: $TIME_LAST"
  echo "****************"
}

# Función para procesar archivos apache.log y out_200.log
process_apache_log() {
  local LOG_FILE=$1
  local INDEX=$2
  # Calcular el hash MD5 del archivo
  MD5=$(md5sum "$LOG_FILE" | cut -d' ' -f1)
  # Cuenta el número total de líneas en el archivo
  TOTAL_LINES=$(wc -l < "$LOG_FILE")
  # Obtiene el nombre del archivo sin la extensión .log
  FILENAME=$(basename "$LOG_FILE" .log)
  
  # Obtenemos la primera y última línea del archivo
  FIRST_RECORD=$(head -n 1 "$LOG_FILE")
  LAST_RECORD=$(tail -n 1 "$LOG_FILE")
  
  # Extraemos la fecha y hora del primer y último registro
  DATE_FIRST=$(echo $FIRST_RECORD | sed 's/.*\[//' | cut -d':' -f1)
  TIME_FIRST=$(echo $FIRST_RECORD | sed 's/.*\[//' | cut -d':' -f2- | cut -d' ' -f1)
  DATE_LAST=$(echo $LAST_RECORD | sed 's/.*\[//' | cut -d':' -f1)
  TIME_LAST=$(echo $LAST_RECORD | sed 's/.*\[//' | cut -d':' -f2- | cut -d' ' -f1)

  # Imprimimos los resultados
  echo "MD5: $MD5"
  echo "Total Number of Lines: $TOTAL_LINES"
  echo "Filename_$INDEX: $FILENAME"
  echo "Date of First Record: $DATE_FIRST"
  echo "Time of First Record: $TIME_FIRST"
  echo "Date of Last Record: $DATE_LAST"
  echo "Time of Last Record: $TIME_LAST"
  echo "****************"
}

# Procesamos cada archivo LOG en el directorio actual
INDEX=1
for LOG_FILE in ./*.log; do
  if [ -f "$LOG_FILE" ]; then
    case $LOG_FILE in
      # Procesa archivos android.log
      *android.log)
        process_android_log "$LOG_FILE" $INDEX
        ;;
      # Procesa archivos apache.log y out_200.log
      *apache.log|*out_200.log)
        process_apache_log "$LOG_FILE" $INDEX
        ;;
    esac
    # Incrementa el índice para el siguiente archivo
    INDEX=$((INDEX+1))
  fi
done


