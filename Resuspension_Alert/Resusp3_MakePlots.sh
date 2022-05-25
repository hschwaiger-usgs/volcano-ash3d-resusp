#!/bin/bash
#date +%j > jday.txt

# This script generates maps of the met conditions for each time step showing
# wind vectors (color scaled from 0 to 20 m/s), snow depth (scaled from 0 to 3 cm)
# and showing the VTTS and Unit H deposits
# To process all 37 files should only take a while.  About 75 seconds
# for step for netcdf conversion and gmt map creation
#
# Usage: Resusp3_MakePlots.sh [yyyymmdd]
#          If argument is not provided, then the UTC date at run time will be used.
#
# Example crontab entry
# 35 6 * * *   /home/ash3d/bin/Resuspension_Alert/Resusp3_MakePlots.sh                > /home/ash3d/cron_logs/resusp3_plots_log 2>&1

if [ -z $1 ]
then
    # Get today's date in UTC time
    yearmonthday=`date -u +%Y%m%d`
  else
    yearmonthday=$1
fi
source $HOME/.bash_profile

USGSROOT="/opt/USGS"
ASH3DROOT="${USGSROOT}/Ash3d"
ASH3DBINDIR="${ASH3DROOT}/bin"
ASH3DSCRIPTDIR="${ASH3DROOT}/bin/scripts"
WINDROOT=/data/WindFiles
NAMAKDATAHOME="${WINDROOT}/nam/091"
FC_day=${yearmonthday}_00                        #name of directory containing current files
USEPODMAN="F"

#ResuspHTTP=/webdata/int-vsc-ash.wr.usgs.gov/htdocs/Resusp
ResuspHTTP=/data/www/vsc-ash.wr.usgs.gov/Resusp

loc_start_date=`date`
echo "-----------------------------------------------------------"
echo "Running Resusp3_MakePlots.sh at ${loc_start_date}"
echo "  Maps will be copied to ${ResuspHTTP}"
echo "-----------------------------------------------------------"

# sanity check
if [ -d "$NAMAKDATAHOME/$FC_day" ]; then
  echo "cd $NAMAKDATAHOME/$FC_day"
  cd $NAMAKDATAHOME/$FC_day
  FULLRUNDIR=`pwd`
else
  echo "ERROR: cannot find download directory $NAMAKDATAHOME/$FC_day"
  exit
fi

#******************************************************************************
#START EXECUTING

if [ "$USEPODMAN" == "T" ]; then
  podman  run --rm -v ${FULLRUNDIR}:/run/user/1004/libpod/tmp:z ash3dpp_res /opt/USGS/Ash3d/bin/scripts/NAMMet_to_gif.sh ${FULLRUNDIR}
else
  echo "Running ${ASH3DSCRIPTDIR}/NAMMet_to_gif.sh ${FULLRUNDIR}"
  ${ASH3DSCRIPTDIR}/NAMMet_to_gif.sh ${FULLRUNDIR}
fi

loc_end_date=`date`
echo "-----------------------------------------------------------"
echo "Finished Resusp3_MakePlots.sh at ${loc_end_date}"
echo "-----------------------------------------------------------"

