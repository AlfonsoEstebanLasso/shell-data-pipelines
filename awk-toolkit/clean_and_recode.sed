#!/bin/sed -f

# Delete records if the "city" or "duration (seconds)" field is empty
/,\s*,/d
/,,$/d

# Change numeric durations strictly less than 100 to "Short"
s/,\([0-9]\{1,2\}\(\.[0-9]*\)\?\),/,Short,/

# Change numeric durations greater than or equal to 100 to "Long"
s/,\([0-9]\{3,\}\(\.[0-9]*\)\?\),/,Long,/

