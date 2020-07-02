#!/bin/bash

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
DepFile="Katmai_H_deposit_outline_Sat_LonLat.csv"

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

ResuspBinDir=/home/ash3d/bin/Resuspension_Alert
#ResuspFileDir=/opt/USGS/Ash3d/share/Resuspension_today
ResuspWorkDir=/home/ash3d/Resuspension_today

cd ${ResuspWorkDir}
cat ${ResuspBinDir}/Katmai_regionalH_FC_iwf13_3_LL_top.inp > ash3d_resusp.inp
echo "0 0 0 0.0 ${RunDur} ${Height} ${EmissionScheme} ${Ustar} ${Fv_coeff}" >> ash3d_resusp.inp
echo "dep_contour.csv" >> ash3d_resusp.inp
cat ${ResuspBinDir}/Katmai_regionalH_FC_iwf13_3_LL_bot.inp >> ash3d_resusp.inp
cp ${ResuspBinDir}/${DepFile} ${ResuspWorkDir}/

#-----------------------------------------------------
# Now calling the run script
${ResuspBinDir}/runAsh3d_resusp.sh temp F F
#-----------------------------------------------------

mv ${ResuspWorkDir}/temp ${ResuspWorkDir}/temp_${yearmonthday}

loc_end_date=`date`
echo "-----------------------------------------------------------"
echo "Finished Resusp4_runAsh3d_Katmai.sh at ${loc_end_date}"
echo "-----------------------------------------------------------"

