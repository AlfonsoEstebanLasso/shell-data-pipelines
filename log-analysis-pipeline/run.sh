#!/bin/bash

# Step A: Runs a.sh to download and process the logs.zip file
chmod +x a.sh
# Runs the a.sh script with the provided URL to download and process logs.zip
./a.sh https://drive.google.com/file/d/YOUR_FILE_ID/download?usp=drive_link/logs.zip

# Step B: Runs b.sh to process apache.log for different HTTP codes
chmod +x b.sh
# Runs b.sh to process apache.log filtering by HTTP code 200 and generates out_200.log
./b.sh ./apache.log 200 out_200.log


# Runs b.sh to process apache.log filtering by HTTP code 304 and generates out_304.log
./b.sh ./apache.log 304 out_304.log


# Runs b.sh to process apache.log filtering by HTTP code 404 and generates out_404.log
./b.sh ./apache.log 404 out_404.log

# The following lines contain possible errors or inconsistencies:
./b.sh ./apache.log
# The second and third parameters are not provided, which may cause an error according to the definition of b.sh

./b.sh ./apache.csv 404 out_404.log
# Provides a CSV file instead of a log file, which may not be expected by b.sh

./b.sh ./apache.log 404 out_304.log
# The output file name does not match the filtered HTTP code, which produces an error according to the logic of b.sh

./b.sh ./apache.log 300 out_300.log
# HTTP code 300 is not in the list of allowed codes, which produces an error according to the logic of b.sh

# Step C: Runs c.sh to analyze out_200.log
chmod +x c.sh
# Runs the c.sh script to analyze the out_200.log file
./c.sh ./out_200.log

# Step D: Runs d.sh to analyze the android.log file
chmod +x d.sh
# Runs the d.sh script to analyze the android.log file
./d.sh ./android.log

# Final message indicating that all the scripts have run correctly
echo "Todos los scripts se han ejecutado correctamente."

