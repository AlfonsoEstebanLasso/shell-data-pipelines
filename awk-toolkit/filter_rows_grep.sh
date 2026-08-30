#!/usr/bin/env bash
grep -E "[[:digit:]][[:digit:]],F,1[[:digit:]],finnish,.* french spanish .*|[[:digit:]][[:digit:]],F,3[[:digit:]],finnish,.* spanish french" demographic_info.csv

