BEGIN {
    FS = ",";  # Establecemos la coma como delimitador de campos
    OFS = ","; # Establecemos la coma como delimitador de salida
}

NR == 1 {
    # Guardamos la cabecera y la escribimos en los archivos de salida
    header = $0;
    print header > "country_wrong.csv"
    print header > "duration_wrong.csv"
    print header > "date_posted_wrong.csv"
}

NR > 1 {
    # Verificamos de "country"
    if (length($4) != 2) {
        print $0 > "country_wrong.csv"
    }

    # Verificamos de "duration (seconds)"
    if ($6 != "" && ($6 ~ /\./ || $6+0 != $6)) {
        print $0 > "duration_wrong.csv"
    }

    # Verificamos "date posted"
    split($9, date, "/")
    month = date[1]
    day = date[2]
    year = date[3]
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900 || year > 2024) {
        print $0 > "date_posted_wrong.csv"
    }
}

END {
    # Cerrar archivos para asegurar que se escriben los buffers
    close("country_wrong.csv")
    close("duration_wrong.csv")
    close("date_posted_wrong.csv")
}

