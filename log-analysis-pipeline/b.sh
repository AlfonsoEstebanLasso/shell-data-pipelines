#!/bin/bash

# Function to show errors and exit
error_exit() {
  echo "$1"
  exit 1
}

# Check whether three parameters were provided
if [ $# -ne 3 ]; then
  error_exit "Error: mandatory parameter not found"
fi

# Assign parameters to variables
LOG_FILE="$1"
CODE="$2"
OUTPUT_FILE="$3"

# Check whether the first parameter is a valid file
if [ ! -f "$LOG_FILE" ]; then
  error_exit "Error: mandatory parameter is not a valid file"
fi

# Check whether the second and third parameters have the same code
EXPECTED_OUTPUT_FILE="out_${CODE}.log"
if [ "$OUTPUT_FILE" != "$EXPECTED_OUTPUT_FILE" ]; then
  error_exit "Error: different codes"
fi

# Check whether the code is one of the allowed ones (200, 304, 404)
if [[ "$CODE" != "200" && "$CODE" != "304" && "$CODE" != "404" ]]; then
  error_exit "Error: wrong code"
fi

# Filter the lines of the log file by the HTTP code and save them to the output file
grep " $CODE " "$LOG_FILE" > "$OUTPUT_FILE"


