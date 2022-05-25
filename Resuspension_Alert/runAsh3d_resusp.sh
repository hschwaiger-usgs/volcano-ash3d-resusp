#!/bin/bash

#      This file is a component of the volcanic ash transport and dispersion model Ash3d,
#      written at the U.S. Geological Survey by Hans F. Schwaiger (hschwaiger@usgs.gov),
#      Larry G. Mastin (lgmastin@usgs.gov), and Roger P. Denlinger (roger@usgs.gov).

#      The model and its source code are products of the U.S. Federal Government and therefore
#      bear no copyright.  They may be copied, redistributed and freely incorporated 
#      into derivative products.  However as a matter of scientific courtesy we ask that
#      you credit the authors and cite published documentation of this model (below) when
#      publishing or distributing derivative products.

#      Schwaiger, H.F., Denlinger, R.P., and Mastin, L.G., 2012, Ash3d, a finite-
#         volume, conservative numerical model for ash transport and tephra deposition,
#         Journal of Geophysical Research, 117, B04204, doi:10.1029/2011JB008968. 

#      We make no guarantees, expressed or implied, as to the usefulness of the software
#      and its documentation for any purpose.  We assume no responsibility to provide
#      technical support to users of this software.

echo "------------------------------------------------------------"
echo "running runAsh3d_resusp.sh rundir out F F"
echo `date`
echo "------------------------------------------------------------"

t0=`date -u`                                     # record start time
rc=0                                             # error message accumulator

HOST=`hostname | cut -c1-9`
echo "HOST=$HOST"

USGSROOT="/opt/USGS"
ASH3DROOT="${USGSROOT}/Ash3d"
WINDROOT="/data/WindFiles"

ASH3DBINDIR="${ASH3DROOT}/bin"
ASH3DEXEC="${ASH3DBINDIR}/Ash3d_res"
#ASH3DEXEC="${ASH3DBINDIR}/Ash3d_vog_SnD01"
ASH3DSCRIPTDIR="${ASH3DROOT}/bin/autorun_scripts"
ASH3DWEBSCRIPTDIR="${ASH3DROOT}/bin/ash3dweb_scripts"
ASH3DSHARE="$ASH3DROOT/share"
ASH3DSHARE_PP="${ASH3DSHARE}/post_proc"

NAMDATAHOME="${WINDROOT}/nam/091"
#
#Determine last downloaded windfile
#LAST_DOWNLOADED=`cat ${WINDROOT}/gfs/last_downloaded.txt`
#echo "last downloaded windfile =${LAST_DOWNLOADED}"

#Assign default filenames and directory names
#INFILE_MAIN="Katmai_regionalH_FC_iwf13_3_LL.inp"                 #input file used for main Ash3d run
INFILE_MAIN="ash3d_resusp.inp"

echo "checking input argument"
if [ -z $1 ]
then
    echo "Error: you must specify an input directory containing the file ash3d_input_ac.inp"
    exit 1
  else
    RUNDIR=$1
    echo "run directory is $1"
fi

if [ -z $2 ]
then
	echo "Error: you must specify a zip file name"
	exit 1
else
        #ZIPNAME=`echo $2 | tr '/' '-'`        #if there are slashes in the name, replace them with dashes
        ZIPNAME=$2
fi

DASHBOARD_RUN=$3

ADVANCED_RUN=$4
echo "ADVANCED_RUN = $ADVANCED_RUN"
if [ "$ADVANCED_RUN" = "advanced1" ]; then
    echo "Advanced run, preliminary."
  elif [ "$ADVANCED_RUN" = "advanced2" ]; then
    echo "Advanced run using main input file"
fi

echo "changing directories to ${RUNDIR}"
if test -r ${RUNDIR}
then
    cd $RUNDIR
    echo "DASHBOARD_RUN = $DASHBOARD_RUN $3" > test.txt
  else
    mkdir -p $RUNDIR
    cd $RUNDIR
    #echo "Error: Directory ${RUNDIR} does not exist."
    #exit 1
fi

if [[ $? -ne 0 ]]; then
           rc=$((rc + 1))
fi

#if it's an advanced tab run and argument 4 is set to "advanced2",
#then skip to the last half of the script and read directly from the
#input file
if [ "$ADVANCED_RUN" != "advanced2" ]; then

   echo "removing old input & output files"
   echo "rm -f *.gif *.kmz *.zip ${INFILE_PRELIM} *.txt cities.xy *.dat *.pdf 3d_tephra_fall.nc"
   rm -f *.gif *.kmz *.zip ${INFILE_PRELIM} *.txt cities.xy *.dat *.pdf 3d_tephra_fall.nc
   rc=$((rc + $?))
   echo "rc=$rc"

   echo "copying airports file, cities file, and readme file"
   cp ${ASH3DSHARE}/GlobalAirports_ewert.txt .
   cp ${ASH3DSHARE}/readme.pdf .
   cp ${ASH3DSHARE_PP}/USGS_warning3.png .
   ln -s ${ASH3DSHARE_PP}/world_cities.txt .
   ln -s ${USGSROOT}/data/Topo/GEBCO_08.nc .
   ln -s ${USGSROOT}/data/Landcover .
   cp ${ASH3DSHARE_PP}/concentration_legend.png .
   cp ${ASH3DSHARE_PP}/CloudHeight_hsv.jpg .
   cp ${ASH3DSHARE_PP}/CloudLoad_hsv.png .
   cp ${ASH3DSHARE_PP}/cloud_arrival_time.png .
   #cp /opt/USGS/Ash3d/share/Resuspension_today/Katmai_H_deposit_outline_Sat_LonLat.csv .
   #cp /opt/USGS/Ash3d/share/Resuspension_today/${INFILE_MAIN} .
   deplines=`wc -l ../Katmai_H_deposit_outline_Sat_LonLat.csv | cut -d' ' -f1`
   echo "${deplines}" > dep_contour.csv
   cat ../Katmai_H_deposit_outline_Sat_LonLat.csv >> dep_contour.csv
   cp ../ash3d_resusp.inp .
   rc=$((rc + $?))
   echo "rc=$rc"

   echo "creating soft links to wind files"
   rm nam.t*
   ln -s  ${NAMDATAHOME}/latest/nam.*.grib2 .
   rc=$((rc + $?))
   echo "rc=$rc"
fi    #End of block skipped when $ADVANCED_RUN="advanced2"

echo "removing .dat file, preliminary ash3d input file"
echo "rm -f *.dat"
rm -f *.dat

if [ "$ADVANCED_RUN" = "advanced1" ]; then
    echo "Created input file for advanced tab.  Stopping"
    exit
fi

echo "*******************************************************************************"
echo "*******************************************************************************"
echo "**********                   Main Ash3d run                          **********"
echo "*******************************************************************************"
echo "*******************************************************************************"
${ASH3DEXEC} ${INFILE_MAIN}
#| tee ashlog.txt
echo "-------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------"
echo "----------                Completed  Main Ash3d run                  ----------"
echo "-------------------------------------------------------------------------------"
echo "-------------------------------------------------------------------------------"
rc=$((rc + $?))
echo "rc=$rc"

echo "zipping up kml files"
zip cloud_arrivaltimes_airports.kmz AshArrivalTimes.kml    USGS_warning3.png depTS*png
rc=$((rc + $?))
zip cloud_arrivaltimes_hours.kmz    CloudArrivalTime.kml   USGS_warning3.png cloud_arrival_time.png
rc=$((rc + $?))
zip CloudConcentration.kmz          CloudConcentration.kml USGS_warning3.png concentration_legend.png
rc=$((rc + $?))
zip CloudHeight.kmz                 CloudHeight.kml        USGS_warning3.png CloudHeight_hsv.jpg
rc=$((rc + $?))
zip CloudLoad.kmz                   CloudLoad.kml          USGS_warning3.png CloudLoad_hsv.png
rc=$((rc + $?))
echo "rc=$rc"
if [[ "$rc" -gt 0 ]] ; then
    echo "Error: rc=$rc"
    exit 1
fi

echo "running makeAshArrivalTimes_ac"
${ASH3DBINDIR}/makeAshArrivalTimes_ac
rc=$((rc+$?))
echo "rc=$rc"

echo "moving AshArrivalTimes.txt to AshArrivalTimes_old.txt"
mv AshArrivalTimes.txt AshArrivalTimes_old.txt
rc=$((rc+$?))
echo "rc=$rc"
if [[ "$rc" -gt 0 ]] ; then
    echo "Error: rc=$rc"
    exit 1
fi
echo "overwriting AshArrivalTimes.txt"
mv AshArrivalTimes_ac.txt AshArrivalTimes.txt
rc=$((rc+$?))
echo "rc=$rc"
if [[ "$rc" -gt 0 ]] ; then
    echo "Error: rc=$rc"
    exit 1
fi

#convert line endings from unix to dos
#sed 's/$/\r/' AshArrivalTimes.txt > AshArrivalTimes2.txt
#mv AshArrivalTimes2.txt AshArrivalTimes.txt
unix2dos AshArrivalTimes.txt
rc=$((rc+$?))
if [[ "$rc" -gt 0 ]] ; then
    echo "Error: rc=$rc"
    exit 1
fi

echo "removing extraneous files"
echo "rm -f *.kml"
rm -f *.kml
rc=$((rc+$?))
echo "rc=$rc"
if [[ "$rc" -gt 0 ]] ; then
    echo "Error: rc=$rc"
    exit 1
fi

echo "started run at:  $t0" >> Ash3d.lst
echo "  ended run at: " `date` >> Ash3d.lst

echo "creating gif images of ash cloud"
# Generate gifs for the transient variables
#  0 = depothick
#  1 = ashcon_max
#  2 = cloud_height
#  3 = cloud_load
#    Cloud load is the default, so run that one first
#      Note:  the animate gif for this variable is copied to "cloud_animation.gif"
echo "Calling ${ASH3DWEBSCRIPTDIR}/NAM198Volc_to_gif_tvar.sh 3"
${ASH3DWEBSCRIPTDIR}/NAM198Volc_to_gif_tvar.sh 3

#    Now run it for cloud_height
#echo "Calling NAM198Volc_to_gif_tvar.sh 2"
#${ASH3DWEBSCRIPTDIR}/NAM198Volc_to_gif_tvar.sh 2
#rc=$((rc+$?))
#echo "rc=$rc"

#cp cloud_animation.gif output_FC.gif          #to be used until we change the name in the GUI
#rc=$((rc+$?))
#echo "rc=$rc"

echo "started run at:  $t0" >> Ash3d.lst
echo "  ended run at: " `date` >> Ash3d.lst


#Assign a name to the zip file
#year=`date -u | cut -c25-28`
#month=`date -u | cut -c5-7`
#day=`date -u | cut -c9-10`
#hhmm=`date -u | cut -c12-16`
#ZIPFILENAME="${volc}_${year}${month}${day}.${hhmm}UTC"

echo "copying AshArrivalTimes.txt to cloud_arrivaltimes_airports.txt"
#cp AshArrivalTimes.txt cloud_arrivaltimes_airports.txt
#rc=$((rc+$?))
#echo "rc=$rc"

#sed 's/$/\r/' ${INFILE_MAIN} > ${INFILE_MAIN}2
#mv ${INFILE_MAIN}2 ${INFILE_MAIN}
unix2dos -m ${INFILE_MAIN}

#zip $ZIPNAME.zip *UTC*.gif cloud_animation.gif cloud_arrivaltimes_airports.txt ${INFILE_MAIN} \
#    cloud_arrivaltimes_airports.kmz cloud_arrivaltimes_hours.kmz CloudConcentration.kmz CloudHeight.kmz \
#    CloudLoad.kmz readme.pdf
#rc=$((rc + $?))

cp /opt/USGS/Ash3d/bin/ash3dweb_scripts/plot_vprof.m plot_vprof
./plot_vprof

cp cloud_load_animation.gif /webdata/int-vsc-ash.wr.usgs.gov/htdocs/Resusp/Animation_Ash3d_CloudLoad.gif
cp vprofile*.txt /webdata/int-vsc-ash.wr.usgs.gov/htdocs/Resusp/
cp AirConcen*png /webdata/int-vsc-ash.wr.usgs.gov/htdocs/Resusp/

# Now evaulate the vprofile[01,02,03,04].txt files to see if any ash hit those four points along the Shelikof Strait
# Right now, just check the size of the files.  They will just contain the header (594 bytes) if no ash is logged, but
# might have a 10 or 20 kb if there is a light dusting.  Check if any file exceeds some size threshold.
#VPROFTHRESH=20000
#V1=`wc -c vprofile01.txt | cut -d' ' -f1`
#V2=`wc -c vprofile02.txt | cut -d' ' -f1`
#V3=`wc -c vprofile03.txt | cut -d' ' -f1`
#V4=`wc -c vprofile04.txt | cut -d' ' -f1`
#if [ $V1 -gt $VPROFTHRESH ];then
#  /usr/bin/python /home/ash3d/bin/Resuspension_Alert/Resusp_TextWarning_Ash3d.py
#elif [ $V2 -gt $VPROFTHRESH ];then
#  /usr/bin/python /home/ash3d/bin/Resuspension_Alert/Resusp_TextWarning_Ash3d.py
#elif [ $V3 -gt $VPROFTHRESH ];then
#  /usr/bin/python /home/ash3d/bin/Resuspension_Alert/Resusp_TextWarning_Ash3d.py
#elif [ $V4 -gt $VPROFTHRESH ];then
#  /usr/bin/python /home/ash3d/bin/Resuspension_Alert/Resusp_TextWarning_Ash3d.py
#fi

# Now evaluate the output nc file and check for a cloud load exceeding some
# theshold (0.01) at the 4 points along the Shelikof Strait
VPROFTHRESH=1
${ASH3DWEBSCRIPTDIR}/test_Shelikof_points.sh
V1=`wc -c foundash.txt | cut -d' ' -f1`
if [ $V1 -gt $VPROFTHRESH ];then
  /usr/bin/python /home/ash3d/bin/Resuspension_Alert/Resusp_TextWarning_Ash3d.py
fi

echo "removing extraneous files"
echo "rm -f tmp1.txt tmp2.txt"
echo "rm -f *.cpt caption.txt fort.18 current_time.txt dep_thick.txt  Temp.epsi cities.xy"
echo "rm -f USGS_warning3.png concentration_legend.png CloudHeight_hsv.jpg CloudLoad_hsv.png cloud_arrival_time.png"
echo "rm -f world_cities.txt test.txt"
#rm -f tmp1.txt tmp2.txt
#rm -f *.cpt caption.txt fort.18 current_time.txt dep_thick.txt  Temp.epsi cities.xy
#rm -f USGS_warning3.png concentration_legend.png CloudHeight_hsv.jpg CloudLoad_hsv.png cloud_arrival_time.png
#rm -f world_cities.txt test.txt

if [[ $rc -ne 0 ]]; then
	echo "$rc errors detected."
else
	echo "successful completion"
fi

t1=`date -u`
echo "started run at:  $t0"
echo "  ended run at:  $t1"
echo "all done with run $4"

exit $rc

