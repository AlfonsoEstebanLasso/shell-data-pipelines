BEGIN {
    FS = ",";  # Set the comma as the field delimiter
    OFS = ","; # Set the comma as the output delimiter
}

NR == 1 {
    # Save the header and write it to the output files
    header = $0;
    print header > "country_wrong.csv"
    print header > "duration_wrong.csv"
    print header > "date_posted_wrong.csv"
}

NR > 1 {
    # Check "country"
    if (length($4) != 2) {
        print $0 > "country_wrong.csv"
    }

    # Check "duration (seconds)"
    if ($6 != "" && ($6 ~ /\./ || $6+0 != $6)) {
        print $0 > "duration_wrong.csv"
    }

    # Check "date posted"
    split($9, date, "/")
    month = date[1]
    day = date[2]
    year = date[3]
    if (month < 1 || month > 12 || day < 1 || day > 31 || year < 1900 || year > 2024) {
        print $0 > "date_posted_wrong.csv"
    }
}

END {
    # Close files to ensure the buffers are written
    close("country_wrong.csv")
    close("duration_wrong.csv")
    close("date_posted_wrong.csv")
}

