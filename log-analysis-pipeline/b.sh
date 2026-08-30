#!/bin/bash

# Función para mostrar errores y salir
error_exit() {
  echo "$1"
  exit 1
}

# Verificamos si se proporcionaron tres parámetros
if [ $# -ne 3 ]; then
  error_exit "Error: mandatory parameter not found"
fi

# Asignamos parámetros a variables
LOG_FILE="$1"
CODE="$2"
OUTPUT_FILE="$3"

# Verificamos si el primer parámetro es un archivo válido
if [ ! -f "$LOG_FILE" ]; then
  error_exit "Error: mandatory parameter is not a valid file"
fi

# Verificamos si el segundo y tercer parámetro tienen el mismo código
EXPECTED_OUTPUT_FILE="out_${CODE}.log"
if [ "$OUTPUT_FILE" != "$EXPECTED_OUTPUT_FILE" ]; then
  error_exit "Error: different codes"
fi

# Verificamos si el código es uno de los permitidos (200, 304, 404)
if [[ "$CODE" != "200" && "$CODE" != "304" && "$CODE" != "404" ]]; then
  error_exit "Error: wrong code"
fi

# Filtramos las líneas del archivo de log por el código HTTP y guardarlas en el archivo de salida
grep " $CODE " "$LOG_FILE" > "$OUTPUT_FILE"


