#!/bin/bash

# Verificamos si se proporcionó un archivo como parámetro
if [ -z "$1" ]; then
  # Si no se proporciona un parámetro, mostrar el uso correcto y salir con código de error 1
  echo "Uso: $0 <archivo_log>"
  exit 1
fi

# Asignamos el primer parámetro a la variable LOG_FILE
LOG_FILE="$1"
# Definir nombres de archivos de salida
CSV_FILE="url_counts.csv"
PERCENTAGE_GRAPH_FILE="url_percentage_visits.png"
VISITS_GRAPH_FILE="url_visits.png"

# Verificamos si el archivo de log existe
if [ ! -f "$LOG_FILE" ]; then
  # Si el archivo no existe, mostrar error y salir
  echo "Error: El archivo $LOG_FILE no existe."
  exit 1
fi

# Procesamos el archivo de log para extraer URLs y contar visitas
awk '{print $1, $10}' "$LOG_FILE" | sed 's#^http[s]*://##' | sed 's#^www\.##' | cut -d'/' -f1 | \
awk '
  {
    count[$1]++;        # Contar las ocurrencias de cada URL
    visits[$1]+=$2;     # Sumar el número de visitas para cada URL
  }
  END {
    total_visits=0;
    for (url in count) {
      total_visits += visits[url];  # Calcular el total de visitas
    }
    print "URL,Count,Visits,Percentage";
    for (url in count) {
      percentage = (visits[url] / total_visits) * 100;  # Calcular el porcentaje de visitas
      print url "," count[url] "," visits[url] "," percentage;
      if (percentage > 1) {
        # Guardar URLs con más del 1% de visitas en un archivo temporal
        print url "," visits[url] "," percentage > "/tmp/filtered_urls.csv";
      }
    }
  }
' > "$CSV_FILE"  # Guardamos la salida en el archivo CSV

# Generamos gráfica de porcentaje con Gnuplot para URLs con mínimo un 1% de visitas
gnuplot <<- EOF
  set terminal png size 800,600
  set output "$PERCENTAGE_GRAPH_FILE"
  set datafile separator comma
  set style data histogram
  set style fill solid
  set xlabel "URL"
  set ylabel "Percentage of Visits"
  set title "URL Visit Percentages"
  set xtics rotate by -45
  plot "/tmp/filtered_urls.csv" using 3:xtic(1) title 'Percentage'
EOF

# Generamos gráfica de número de visitas con Gnuplot para URLs con mínimo un 1% de visitas
gnuplot <<- EOF
  set terminal png size 800,600
  set output "$VISITS_GRAPH_FILE"
  set datafile separator comma
  set style data histogram
  set style fill solid
  set xlabel "URL"
  set ylabel "Number of Visits"
  set title "URL Visit Counts"
  set xtics rotate by -45
  plot "/tmp/filtered_urls.csv" using 2:xtic(1) title 'Visits'
EOF

# Mensajes de confirmación
echo "El archivo CSV se ha generado como $CSV_FILE."
echo "Los gráficos se han generado como $PERCENTAGE_GRAPH_FILE y $VISITS_GRAPH_FILE."

