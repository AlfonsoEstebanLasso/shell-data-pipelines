#!/usr/bin/env bash
sed "{
s/F/Female/g
s/M/Male/g
/O/d
}" demographic_info.csv 

