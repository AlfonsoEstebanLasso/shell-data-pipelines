#!/bin/bash

# Step A: Ejecuta a.sh para descargar y procesar el archivo logs.zip
chmod +x a.sh
# Ejecuta el script a.sh con la URL proporcionada para descargar y procesar logs.zip
./a.sh https://drive.google.com/file/d/YOUR_FILE_ID/download?usp=drive_link/logs.zip

# Step B: Ejecuta b.sh para procesar apache.log para diferentes códigos HTTP
chmod +x b.sh
# Ejecuta b.sh para procesar apache.log filtrando por el código HTTP 200 y genera out_200.log
./b.sh ./apache.log 200 out_200.log


# Ejecuta b.sh para procesar apache.log filtrando por el código HTTP 304 y genera out_304.log
./b.sh ./apache.log 304 out_304.log


# Ejecuta b.sh para procesar apache.log filtrando por el código HTTP 404 y genera out_404.log
./b.sh ./apache.log 404 out_404.log

# Las siguientes líneas contienen posibles errores o inconsistencias:
./b.sh ./apache.log
# No se proporciona el segundo y tercer parámetro, lo que puede causar un error según la definición de b.sh

./b.sh ./apache.csv 404 out_404.log
# Proporciona un archivo CSV en lugar de un archivo de log, lo que puede no ser esperado por b.sh

./b.sh ./apache.log 404 out_304.log
# El nombre del archivo de salida no coincide con el código HTTP filtrado, lo que genera un error según la lógica de b.sh

./b.sh ./apache.log 300 out_300.log
# El código HTTP 300 no está en la lista de códigos permitidos, lo que genera un error según la lógica de b.sh

# Step C: Ejecuta c.sh para analizar out_200.log
chmod +x c.sh
# Ejecuta el script c.sh para analizar el archivo out_200.log
./c.sh ./out_200.log

# Step D: Ejecuta d.sh para analizar el archivo android.log
chmod +x d.sh
# Ejecuta el script d.sh para analizar el archivo android.log
./d.sh ./android.log

# Mensaje final indicando que todos los scripts se han ejecutado correctamente
echo "Todos los scripts se han ejecutado correctamente."

