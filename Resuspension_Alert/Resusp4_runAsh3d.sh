#!/bin/bash

# This script initiates the daily Ash3d run for the Katmai resuspension cases
# as a cron job.  Really, it just prepares the input file based on setting in
# the top of this script, creates a temporary folder, then calls the more
# general script runAsh3d_resusp.sh which is structured similar to the
# cloud and deposit Ash3d web-scripts

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

#ResuspHTTP=/webdata/int-vsc-ash.wr.usgs.gov/htdocs/Resusp
ResuspHTTP=/data/www/vsc-ash.wr.usgs.gov/Resusp

RunDur="35.0"
Height="5.0"
EmissionScheme="3"
Ustar="0.55"
Fv_coeff="3.3e-8"
DepFile="Novarupta/Novarupta_H_deposit_outline_Sat_LonLat.csv"

loc_start_date=`date`
echo "-----------------------------------------------------------"
echo "Running Resusp4_runAsh3d_Katmai.sh at ${loc_start_date}"
echo " Using the following resuspension parameters:"
echo "   Run Duration        = ${RunDur}"
echo "   Height              = ${Height}"
echo "   Emission Scheme     = ${EmissionScheme}   :: (1-west, 2=Lead, 3=Mort)"
echo "   Thresh. Fric. Vel.  = ${Ustar}"
echo "   Vert. Flux Coeff    = ${Fv_coeff}"
echo "   Source contour file = ${DepFile}"
echo "  Output will be copied to ${ResuspHTTP}"
echo "-----------------------------------------------------------"

USGSROOT="/opt/USGS"
ASH3DROOT="${USGSROOT}/Ash3d"
ResuspBinDir=${ASH3DROOT}/bin/Resuspension_Alert
#ResuspFileDir=/opt/USGS/Ash3d/share/Resuspension_today
ResuspWorkDir=${HOME}/Resuspension_today

cd ${ResuspWorkDir}
cat ${ResuspBinDir}/Novarupta/Novarupta_regionalH_FC_iwf13_3_LL_Block1.inp > ash3d_resusp.inp
echo "0 0 0 0.0 ${RunDur} ${Height} ${EmissionScheme} ${Ustar} ${Fv_coeff}" >> ash3d_resusp.inp
echo "dep_contour.csv" >> ash3d_resusp.inp
cat ${ResuspBinDir}/Novarupta/Novarupta_regionalH_FC_iwf13_3_LL_Block3-end.inp >> ash3d_resusp.inp
cp ${ResuspBinDir}/${DepFile} ${ResuspWorkDir}/

#-----------------------------------------------------
# Now calling the run script
${ASH3DROOT}/bin/scripts/runAsh3d_resusp.sh temp F F
#-----------------------------------------------------

mv ${ResuspWorkDir}/temp ${ResuspWorkDir}/temp_${yearmonthday}

loc_end_date=`date`
echo "-----------------------------------------------------------"
echo "Finished Resusp4_runAsh3d_Katmai.sh at ${loc_end_date}"
echo "-----------------------------------------------------------"

