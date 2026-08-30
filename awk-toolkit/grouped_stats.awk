BEGIN {
    FS = ",";  # Establecemos la coma como delimitador de campos
}

{
    if (NR > 1) {  # Ignoramos la cabecera del CSV
        # Procesamos del campo "datetime"
        split($1, dt_parts, " ");
        split(dt_parts[1], date, "/");
        datetime = mktime(date[3] " " date[1] " " date[2] " 00 00 00");

        # Procesamos el campo "date posted"
        split($9, dp_parts, "/");
        dateposted = mktime(dp_parts[3] " " dp_parts[1] " " dp_parts[2] " 00 00 00");

        # Diferencia en segundos y luego convertido a días
        diff = int((dateposted - datetime) / 86400);

        # Agrupamos por "shape" y recogemos las estadísticas
        shape = $5;
        count[shape]++;
        sum[shape] += diff;
        sumsq[shape] += diff * diff;
    }
}

END {
    # Calculamos la media y desviación estándar
    for (s in count) {
        mean = sum[s] / count[s];
        stddev = sqrt((sumsq[s] / count[s]) - (mean * mean));
        printf "%d, %s, %.2f, %.2f\n", count[s], s, mean, stddev;
    }
}

