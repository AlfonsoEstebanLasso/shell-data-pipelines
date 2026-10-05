#!/bin/bash

# Check whether a file was provided as a parameter
if [ -z "$1" ]; then
  # If no parameter is provided, show the correct usage and exit with error code 1
  echo "Uso: $0 <archivo_log>"
  exit 1
fi

# Assign the first parameter to the LOG_FILE variable
LOG_FILE="$1"
# Define output file names
CSV_FILE="component_data.csv"
COMPONENT_GRAPH="component_counts.png"
SECONDS_GRAPH="seconds_counts.png"

# Check whether the log file exists
if [ ! -f "$LOG_FILE" ]; then
  # If the file does not exist, show an error and exit
  echo "Error: El archivo $LOG_FILE no existe."
  exit 1
fi

# Extract components and seconds, count the occurrences and compute the total seconds per component
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
' "$LOG_FILE" | sort -t',' -k2 -nr > "$CSV_FILE"  # Saves the output to the CSV file and sorts by the second column (Count) in descending order

# Confirmation message for the creation of the CSV file
echo "Archivo $CSV_FILE generado con éxito."

# Generate the components chart with gnuplot
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

# Generate the seconds-per-component chart with gnuplot
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

# Confirmation message for the creation of the charts
echo "Gráficos $COMPONENT_GRAPH y $SECONDS_GRAPH generados con éxito."

