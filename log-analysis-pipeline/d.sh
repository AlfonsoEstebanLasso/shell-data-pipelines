#!/bin/bash

# Verificamos si se proporcionó un archivo como parámetro
if [ -z "$1" ]; then
  # Si no se proporciona un parámetro, mostrar el uso correcto y salir con código de error 1
  echo "Uso: $0 <archivo_log>"
  exit 1
fi

# Asignamos el primer parámetro a la variable LOG_FILE
LOG_FILE="$1"
# Definimos nombres de archivos de salida
CSV_FILE="component_data.csv"
COMPONENT_GRAPH="component_counts.png"
SECONDS_GRAPH="seconds_counts.png"

# Verificamos si el archivo de log existe
if [ ! -f "$LOG_FILE" ]; then
  # Si el archivo no existe, mostrar error y salir
  echo "Error: El archivo $LOG_FILE no existe."
  exit 1
fi

# Extraemos componentes y segundos, contar las ocurrencias y calcular el total de segundos por componente
awk '
{
  split($2, time, ":"); 
  seconds=time[3]; 
  component=$6; 
  gsub(":", "", component); 
  count[component]++; 
  component_times[component] += seconds;
}
END {
  print "Component,Count,Total_Seconds";
  for (comp in count) 
    print comp "," count[comp] "," component_times[comp];
}
' "$LOG_FILE" | sort -t',' -k2 -nr > "$CSV_FILE"  # Guarda la salida en el archivo CSV y ordenar por la segunda columna (Count) en orden descendente

# Mensaje de confirmación de creación del archivo CSV
echo "Archivo $CSV_FILE generado con éxito."

# Generamos el gráfico de componentes con gnuplot
gnuplot <<- EOF
  set terminal png size 800,600
  set output "$COMPONENT_GRAPH"
  set datafile separator comma
  set style data histogram
  set style fill solid
  set xlabel "Componente"
  set ylabel "Cantidad de Entradas de Log"
  set title "Top Componentes con Más Entradas de Log"
  set xtics rotate by -45
  plot "$CSV_FILE" using 2:xtic(1) title 'Componentes'
EOF

# Generamos el gráfico de segundos por componente con gnuplot
gnuplot <<- EOF
  set terminal png size 800,600
  set output "$SECONDS_GRAPH"
  set datafile separator comma
  set style data histogram
  set style fill solid
  set xlabel "Componente"
  set ylabel "Segundos Totales"
  set title "Segundos Totales por Componente"
  set xtics rotate by -45
  plot "$CSV_FILE" using 3:xtic(1) title 'Segundos'
EOF

# Mensaje de confirmación de creación de los gráficos
echo "Gráficos $COMPONENT_GRAPH y $SECONDS_GRAPH generados con éxito."

