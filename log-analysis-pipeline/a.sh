#!/bin/bash

# Check whether a URL was provided as a parameter
if [ -z "$1" ]; then
  # If no parameter is provided, show the correct usage and exit with error code 1
  echo "Uso: $0 <URL_del_archivo_ZIP>"
  exit 1
fi

# URL of the ZIP file provided as a parameter
ZIP_URL="$1"
# Name of the ZIP file to save locally
ZIP_FILE="logs.zip"

# Function to download the file from Google Drive
download_from_gdrive() {
  # Extracts the file ID from the URL
  FILE_ID=$(echo "$1" | grep -o 'd/.*' | cut -d'/' -f2)
  # Get the confirmation code needed to download the file
  CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://drive.google.com/uc?export=download&id=${FILE_ID}" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
  # Downloads the file using the confirmation code
  wget --quiet --load-cookies /tmp/cookies.txt "https://drive.google.com/uc?export=download&confirm=${CONFIRM}&id=${FILE_ID}" -O "$2"
  # Removes the temporary cookies
  rm -rf /tmp/cookies.txt
}

# Download the ZIP file from Google Drive
download_from_gdrive "$ZIP_URL" "$ZIP_FILE"

# Extract the contents of the ZIP file into the current directory, suppressing the output
unzip -o $ZIP_FILE > /dev/null 2>&1

# Function to process the android.log file
process_android_log() {
  local LOG_FILE=$1
  local INDEX=$2
  # Computes the MD5 hash of the file
  MD5=$(md5sum "$LOG_FILE" | cut -d' ' -f1)
  # Counts the total number of lines in the file
  TOTAL_LINES=$(wc -l < "$LOG_FILE")
  # Gets the file name without the .log extension
  FILENAME=$(basename "$LOG_FILE" .log)
  
  # Gets the first and last line of the file
  FIRST_RECORD=$(head -n 1 "$LOG_FILE")
  LAST_RECORD=$(tail -n 1 "$LOG_FILE")
  
  # Extract the date and time of the first and last record
  DATE_FIRST=$(echo $FIRST_RECORD | cut -d' ' -f1)
  TIME_FIRST=$(echo $FIRST_RECORD | cut -d' ' -f2)
  DATE_LAST=$(echo $LAST_RECORD | cut -d' ' -f1)
  TIME_LAST=$(echo $LAST_RECORD | cut -d' ' -f2)

  # Print the results
  echo "MD5: $MD5"
  echo "Total Number of Lines: $TOTAL_LINES"
  echo "Filename_$INDEX: $FILENAME"
  echo "Date of First Record: $DATE_FIRST"
  echo "Time of First Record: $TIME_FIRST"
  echo "Date of Last Record: $DATE_LAST"
  echo "Time of Last Record: $TIME_LAST"
  echo "****************"
}

# Function to process apache.log and out_200.log files
process_apache_log() {
  local LOG_FILE=$1
  local INDEX=$2
  # Compute the MD5 hash of the file
  MD5=$(md5sum "$LOG_FILE" | cut -d' ' -f1)
  # Counts the total number of lines in the file
  TOTAL_LINES=$(wc -l < "$LOG_FILE")
  # Gets the file name without the .log extension
  FILENAME=$(basename "$LOG_FILE" .log)
  
  # Get the first and last line of the file
  FIRST_RECORD=$(head -n 1 "$LOG_FILE")
  LAST_RECORD=$(tail -n 1 "$LOG_FILE")
  
  # Extract the date and time of the first and last record
  DATE_FIRST=$(echo $FIRST_RECORD | sed 's/.*\[//' | cut -d':' -f1)
  TIME_FIRST=$(echo $FIRST_RECORD | sed 's/.*\[//' | cut -d':' -f2- | cut -d' ' -f1)
  DATE_LAST=$(echo $LAST_RECORD | sed 's/.*\[//' | cut -d':' -f1)
  TIME_LAST=$(echo $LAST_RECORD | sed 's/.*\[//' | cut -d':' -f2- | cut -d' ' -f1)

  # Print the results
  echo "MD5: $MD5"
  echo "Total Number of Lines: $TOTAL_LINES"
  echo "Filename_$INDEX: $FILENAME"
  echo "Date of First Record: $DATE_FIRST"
  echo "Time of First Record: $TIME_FIRST"
  echo "Date of Last Record: $DATE_LAST"
  echo "Time of Last Record: $TIME_LAST"
  echo "****************"
}

# Process each LOG file in the current directory
INDEX=1
for LOG_FILE in ./*.log; do
  if [ -f "$LOG_FILE" ]; then
    case $LOG_FILE in
      # Processes android.log files
      *android.log)
        process_android_log "$LOG_FILE" $INDEX
        ;;
      # Processes apache.log and out_200.log files
      *apache.log|*out_200.log)
        process_apache_log "$LOG_FILE" $INDEX
        ;;
    esac
    # Increments the index for the next file
    INDEX=$((INDEX+1))
  fi
done


