#!/usr/bin/awk -f
BEGIN {FS=",";found=0;}
{
if ($4 ~"spanish" || $5~"spanish") {found=found+1;sum+=$3} 
}
END {printf "%.2f \n", sum/found}

