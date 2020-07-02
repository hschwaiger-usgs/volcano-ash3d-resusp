#!/bin/bash
#
# This script examines the NAM AK HiRes files (FC 00-36) and extracts the
# meteorological conditions at the KABU site as well as optionally (if npoints > 1)
# the node to the south and the node east.  These are written to text files in the
# forecast directory. The variables probed are:
#   snow depth        (wgb_SnD_{node}_{FC}.dat)
#   friction velocity (wgb_Us_{node}_{FC}.dat)
#   precip rate       (wgb_PRATE_{node}_{FC}.dat)
#   Vol Soil Moist.   (wgb_VSm_{node}_{FC}.dat)
# Note, this script can be run frequently as it will not process files if the probe
# files already exist in the forecast directory.
# To process all 37 files should only take around 2-3 minutes.

# 20 * * * *   /home/ash3d/bin/Resuspension_Alert/Resusp1_Extract_MetAlarmVars.sh     > /home/ash3d/cron_logs/resusp_getvars_log 2>&1

if [ -z $1 ]
then
    # Get today's date in UTC time
    yearmonthday=`date -u +%Y%m%d`
  else
    yearmonthday=$1
fi
source $HOME/.bash_profile

WINDROOT=/data/WindFiles
NAMAKDATAHOME="${WINDROOT}/nam/091"
FC_day=${yearmonthday}_00                        #name of directory containing current files

loc_start_date=`date`
echo "-----------------------------------------------------------"
echo "Running Resusp1_Extract_MetAlarmVars.sh at ${loc_start_date}"
echo "This uses wgrib2 to process the grib2 files in ${NAMAKDATAHOME}/${FC_day}"
echo "to probe select points for met conditions.  Output is written"
echo "to files in the format wgb_[var]_[ip][ip]_[FChour].dat"
echo "-----------------------------------------------------------"

MYWGRIB=/home/ash3d/Programs/Tarballs/grib2/wgrib2/wgrib2
# sanity check
if [ -f ${MYWGRIB} ]; then
  echo "Using ${MYWGRIB} to probe files."
else
  echo "ERROR: cannot file ${MYWGRIB} for probing files."
  exit
fi
if [ -d "$NAMAKDATAHOME/$FC_day" ]; then
  echo "cd $NAMAKDATAHOME/$FC_day"
  cd $NAMAKDATAHOME/$FC_day
else
  echo "ERROR: cannot find download directory $NAMAKDATAHOME/$FC_day"
  exit
fi
#******************************************************************************
#START EXECUTING

#x[388]=-309.633 km
#y[243]=-3363.52 km

#n198
npoints=1
#     KABU,         KABU + 1s,    KABU + 1e
lon=(-155.25961012 -155.25035886 -155.15903991)
lat=(58.27889163    58.22596619  58.28371228)
i=(0 0 1) # KABU, KABU + 1s, KABU + 1e
j=(0 1 0)

# 2d: Surface or otherwise
#  1  Snow_depth_surface                                       SnD       SNOD  surface
#  9  Frictional_Velocity_surface                              Us       FRICV  surface
n2d1=2
datfile2d1=(    "SnD"      "Us" )
GRIBvar2d1=(   "SNOD"   "FRICV" )
GRIBdim2d1=("surface" "surface" )

#  6  Precipitation_rate_surface                               PRATE    PRATE  surface
n2d2=1
datfile2d2=(  "PRATE")
GRIBvar2d2=(  "PRATE")
GRIBdim2d2=("surface")

# 3d:
#  Below Ground (0-0.1 m below ground , 0.1-0.4 m below ground , 0.4-1 m below ground , 1-2 m below ground)
# 1  Volumetric_Soil_Moisture_Content_depth_below_surface_layer           VSm       SOILW (just top value)
n3d1=1
datfile3d1=(  "VSm" )
GRIBvar3d1=("SOILW" )
GRIBdim3d1=("0-0.1 m below ground")
#******************************************************************************
#START EXECUTING

## Initialize all the data files for this day
#rm wgb_*.dat
#for (( ip=0;ip<${npoints};ip++))
#do
# # Surface vars
# for (( iv=0;iv<${n2d1};iv++))
# do
#  touch wgb_${datfile2d1[iv]}_${i[ip]}${j[ip]}.dat
# done
# # Precip vars
# for (( iv=0;iv<${n2d2};iv++))
# do
#  touch wgb_${datfile2d2[iv]}_${i[ip]}${j[ip]}.dat
# done
# # 3d below ground
# for (( iv=0;iv<${n3d1};iv++))
# do
#  touch wgb_${datfile3d1[iv]}_${i[ip]}${j[ip]}.dat
# done
#done


FChour=(00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36)

#for (( FCi=0;FCi<1;FCi++))
for (( FCi=0;FCi<37;FCi++))
do
  INGRIB="nam.t00z.alaskanest.hiresf${FChour[FCi]}.tm00.loc.grib2"
  if [ -f ${INGRIB} ]; then
    echo "${FC_day} ${INGRIB}"
    ${MYWGRIB} ${INGRIB} > gribheader.txt
  
    for (( ip=0;ip<${npoints};ip++))
    do
      echo "${FC_day} ${INGRIB} :: ${ip}/${npoints}"
      # Surface vars
      for (( iv=0;iv<${n2d1};iv++))
      do
       prbfile="wgb_${datfile2d1[iv]}_${i[ip]}${j[ip]}_${FChour[FCi]}.dat"
       if [ ! -f ${prbfile} ]; then
        echo "${FC_day} ${INGRIB} :: ${ip}/${npoints} ${iv}/${n2d1} ${prbfile} ${GRIBvar2d1[iv]} ${GRIBdim2d1[iv]}"
        rec=`grep ${GRIBvar2d1[iv]} gribheader.txt | grep "${GRIBdim2d1[iv]}" | grep -v WTMP |  cut -d':' -f1`
        dum="'^($rec):'"
        echo "${MYWGRIB} ${INGRIB} -match $dum -lon ${lon[ip]} ${lat[ip]} | cut -d'=' -f4" > getrec
        val1=`sh getrec`
        echo "$val1" > ${prbfile}
        echo "                                                          $val1"
       fi
      done
      # Precip vars
      for (( iv=0;iv<${n2d2};iv++))
      do
       prbfile="wgb_${datfile2d2[iv]}_${i[ip]}${j[ip]}_${FChour[FCi]}.dat"
       if [ ! -f ${prbfile} ]; then
        echo "${FC_day} ${INGRIB} :: ${ip}/${npoints} ${iv}/${n2d2} ${prbfile} ${GRIBvar2d2[iv]} ${GRIBdim2d2[iv]}"
        rec=`grep ${GRIBvar2d2[iv]} gribheader.txt | grep "${GRIBdim2d2[iv]}" | grep "hour fcst" |  cut -d':' -f1`
        dum="'^($rec):'"
        echo "${MYWGRIB} ${INGRIB} -match $dum -lon ${lon[ip]} ${lat[ip]} | cut -d'=' -f4" > getrec
        val1=`sh getrec`
        echo "$val1" > ${prbfile}
        echo "                                                          $val1"
       fi
      done
      # 3d below ground
      for (( iv=0;iv<${n3d1};iv++))
      do
       prbfile="wgb_${datfile3d1[iv]}_${i[ip]}${j[ip]}_${FChour[FCi]}.dat"
       if [ ! -f ${prbfile} ]; then
        echo "${FC_day} ${INGRIB} :: ${ip}/${npoints} ${iv}/${n3d1} ${prbfile} ${GRIBvar3d1[iv]} ${GRIBdim3d1[0]}"
        rec=`grep ${GRIBvar3d1[iv]} gribheader.txt | grep "${GRIBdim3d1[0]}" |  cut -d':' -f1`
        dum="'^($rec):'"
        echo "${MYWGRIB} ${INGRIB} -match $dum -lon ${lon[ip]} ${lat[ip]} | cut -d'=' -f4" > getrec
        val1=`sh getrec`
        echo "$val1" > ${prbfile}
        echo "                                                          $val1"
       fi
      done
    done
  else
    echo "ERROR: cannot find NWP file ${INGRIB} "
  fi
done

loc_end_date=`date`
echo "-----------------------------------------------------------"
echo "Finished Resusp1_Extract_MetAlarmVars.sh at ${loc_end_date}"
echo "-----------------------------------------------------------"

