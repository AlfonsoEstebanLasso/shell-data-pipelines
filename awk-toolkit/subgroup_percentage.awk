#!/usr/bin/awk -f
BEGIN {FS=","; found=0; count=0}
{
if ($4 ~"finnish" && $5~"swedish") {found=found+1;}
if ($4 ~"finnish") {count=count+1;}
}
END {printf "%.2f%", (found/count)*100}
