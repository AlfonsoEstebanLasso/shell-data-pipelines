#!/bin/sed -f

# Eliminamos registros si el campo "city" o "duration (seconds)" está vacío
/,\s*,/d
/,,$/d

# Cambiamos duraciones numéricas estrictamente menores que 100 a "Short"
s/,\([0-9]\{1,2\}\(\.[0-9]*\)\?\),/,Short,/

# Cambiamos duraciones numéricas mayores o iguales a 100 a "Long"
s/,\([0-9]\{3,\}\(\.[0-9]*\)\?\),/,Long,/

