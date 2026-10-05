BEGIN {
    FS = ",";  # Set the comma as the field delimiter
}

{
    if (NR > 1) {  # Ignore the CSV header
        # Process the "datetime" field
        split($1, dt_parts, " ");
        split(dt_parts[1], date, "/");
        datetime = mktime(date[3] " " date[1] " " date[2] " 00 00 00");

        # Process the "date posted" field
        split($9, dp_parts, "/");
        dateposted = mktime(dp_parts[3] " " dp_parts[1] " " dp_parts[2] " 00 00 00");

        # Difference in seconds and then converted to days
        diff = int((dateposted - datetime) / 86400);

        # Group by "shape" and collect the statistics
        shape = $5;
        count[shape]++;
        sum[shape] += diff;
        sumsq[shape] += diff * diff;
    }
}

END {
    # Compute the mean and standard deviation
    for (s in count) {
        mean = sum[s] / count[s];
        stddev = sqrt((sumsq[s] / count[s]) - (mean * mean));
        printf "%d, %s, %.2f, %.2f\n", count[s], s, mean, stddev;
    }
}

