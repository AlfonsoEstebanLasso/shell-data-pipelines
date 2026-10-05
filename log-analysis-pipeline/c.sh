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
CSV_FILE="url_counts.csv"
PERCENTAGE_GRAPH_FILE="url_percentage_visits.png"
VISITS_GRAPH_FILE="url_visits.png"

# Check whether the log file exists
if [ ! -f "$LOG_FILE" ]; then
  # If the file does not exist, show an error and exit
  echo "Error: El archivo $LOG_FILE no existe."
  exit 1
fi

# Process the log file to extract URLs and count visits
awk '{print $1, $10}' "$LOG_FILE" | sed 's#^http[s]*://##' | sed 's#^www\.##' | cut -d'/' -f1 | \
awk '
  {
    count[$1]++;        # Count the occurrences of each URL
    visits[$1]+=$2;     # Sum the number of visits for each URL
  }
  END {
    total_visits=0;
    for (url in count) {
      total_visits += visits[url];  # Compute the total visits
    }
    print "URL,Count,Visits,Percentage";
    for (url in count) {
      percentage = (visits[url] / total_visits) * 100;  # Compute the percentage of visits
      print url "," count[url] "," visits[url] "," percentage;
      if (percentage > 1) {
        # Save URLs with more than 1% of the visits to a temporary file
        print url "," visits[url] "," percentage > "/tmp/filtered_urls.csv";
      }
    }
  }
' > "$CSV_FILE"  # Save the output to the CSV file

# Generate the percentage chart with Gnuplot for URLs with at least 1% of the visits
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

# Generate the number-of-visits chart with Gnuplot for URLs with at least 1% of the visits
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

# Confirmation messages
echo "El archivo CSV se ha generado como $CSV_FILE."
echo "Los gráficos se han generado como $PERCENTAGE_GRAPH_FILE y $VISITS_GRAPH_FILE."

