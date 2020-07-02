#!/bin/bash

vpoints=4
vlon=(206.5 206.0 205.5 205.0)
vlat=(58.25 58.0 57.75 57.5)

infile='3d_tephra_fall.nc'
var='cloud_load'

tmax=`ncdump -h $infile | grep "UNLIMITED" | cut -c22-23` # maximum time dimension

foundash=0
rm -f foundash.txt
touch foundash.txt
for (( iv=0;iv<=3;iv++))
do
 for t in `seq 0 $((tmax-1))`;
 do
   value=`ncks -C -d t,$t -d lon,${vlon[iv]} -d lat,${vlat[iv]} -H -Q -s '%f ' -v ${var} ${infile} | tr '_' '0'`
   istrue=`bc <<< "${value}>0.01"`
   if [ $istrue -eq 1 ]; then
     echo "$t $iv" >> foundash.txt
   fi
 done  # end of time loop
done
#ncks -C  -d lon,205.0 -d lat,57.5 -H -Q -s '%f ' -v cloud_load 3d_tephra_fall.nc

