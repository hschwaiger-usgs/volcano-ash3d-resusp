#!/bin/bash
#date +%j > jday.txt

# This script generates maps of the met conditions for each time step showing
# wind vectors (color scaled from 0 to 20 m/s), snow depth (scaled from 0 to 3 cm)
# and showing the VTTS and Unit H deposits
# To process all 37 files should only take a while.  About 75 seconds
# for step for netcdf conversion and gmt map creation

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
USEPODMAN="T"

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
  podman  run --rm -v ${FULLRUNDIR}:/run/user/1004/libpod/tmp:z ash3dpp_res /opt/USGS/Ash3d/bin/scripts/NAMMet_to_gif.sh
else
  ${ASH3DSCRIPTDIR}/NAMMet_to_gif.sh
fi

# We need to know if we must prefix all gmt commands with 'gmt', as required by version 5
#GMTv=5
#echo "Testing for gmt version"
#type gmt >/dev/null 2>&1 || { echo >&2 "Command 'gmt' not found.  Assuming GMTv4."; GMTv=4;}
#GMTpre=("-" "-" "-" "-" " "   "gmt ")
#GMTelp=("-" "-" "-" "-" "ELLIPSOID" "PROJ_ELLIPSOID")
#GMTnan=("-" "-" "-" "-" "-Ts" "-Q")
#GMTrgr=("-" "-" "-" "-" "grdreformat" "grdconvert")
#GMTpen=("-" "-" "-" "-" "/" ",")
#echo "GMT version = ${GMTv}"

#${GMTpre[GMTv]} gmtset PAPER_MEDIA=a3
# Katmai coordinates
#vlt=58.279
#vln=-154.9533
#xmin=-351.268405311  # 381
#xmax=41.6296269151   # 447
#ymin=-3589.67214315208 # 205
#ymax=-3196.77411093  # 271

#xmin=-351.268  # 381
#xmax=41.630   # 447
#ymin=-3589.672 # 205
#ymax=-3196.774  # 271

#${GMTpre[GMTv]} gmtset ${GMTelp[GMTv]} Sphere
#mapscale="10i"
#PROJg=-JS-150/90/${mapscale}       # This is the geographic projection which needs to be the same as the windfile
#PROJp=-JX${mapscale}               # This is the xy projection using the same map scale
#lonw=`echo "${xmin} ${ymin}" | invproj +proj=stere  +lon_0=210  +lat_0=90 +k_0=0.933 +R=6371.229 -f %.10f | cut -f1`
#lats=`echo "${xmin} ${ymin}" | invproj +proj=stere  +lon_0=210  +lat_0=90 +k_0=0.933 +R=6371.229 -f %.10f | cut -f2`
#lone=`echo "${xmax} ${ymax}" | invproj +proj=stere  +lon_0=210  +lat_0=90 +k_0=0.933 +R=6371.229 -f %.10f | cut -f1`
#latn=`echo "${xmax} ${ymax}" | invproj +proj=stere  +lon_0=210  +lat_0=90 +k_0=0.933 +R=6371.229 -f %.10f | cut -f2`
##echo "$lonw $lats $lone $latn"
#AREA="-R${lonw}/${lats}/${lone}/${latn}r"
#BASE="-Ba2g2/2g1 -P"
#BASE="-Bg2/g1 -P"
#DETAIL="-Df"
#COAST="-W5"

#makecpt -T0/0.03/0.03 -I -Z -Cocean > snwdpth.cpt
##makecpt -T0/20/20 -Z -Crainbow > ws.cpt
#makecpt -T0/20/20 -Z -Ccool > ws.cpt
#makecpt -T0/2.6/2.6 -Z -Crainbow > srfrgh.cpt

#tmax=37
##tmax=2
#FChour=(00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36)

#for tii in `seq 0 $((tmax-1))`;
#do
# if test "$tii" -lt 10
# then
#  tlabel="0$tii"
# else
#  tlabel="$tii"
# fi
# outfile=Katmai_NAM091_${FC_day}_${tlabel}.gif
# grbfile=nam.t00z.alaskanest.hiresf${tlabel}.tm00.loc.grib2
# infile=nam.t00z.alaskanest.hiresf${tlabel}.tm00.loc.grib2.nc
#
# if [ -f ${outfile} ]; then
#   # If map has already been made, cycle to next step
#   continue
# else
#   if [ -f ${grbfile} ]; then
#     # Here's a fresh grib file; process it and make a map
#     /home/ash3d/bin/grib2nc.sh ${grbfile}
#     ${GMTpre[GMTv]} ${GMTrgr[GMTv]} "${infile}?Snow_depth_surface[0]" snowdepth_${tlabel}.grd
#     #${GMTpre[GMTv]} ${GMTrgr[GMTv]} "${infile}?Frictional_Velocity_surface[0]" ustar_${tlabel}.grd
#     ${GMTpre[GMTv]} ${GMTrgr[GMTv]} "${infile}?Wind_speed_gust_surface[0,0]" windspeed_${tlabel}.grd
#     ${GMTpre[GMTv]} ${GMTrgr[GMTv]} "${infile}?u-component_of_wind_isobaric[0,41]" u10_${tlabel}.grd
#     ${GMTpre[GMTv]} ${GMTrgr[GMTv]} "${infile}?v-component_of_wind_isobaric[0,41]" v10_${tlabel}.grd
#
#     ${GMTpre[GMTv]} grdcut snowdepth_${tlabel}.grd -GSnowDepth_sub.grd -R${xmin}/${xmax}/${ymin}/${ymax} 2> /dev/null
#     #${GMTpre[GMTv]} grdcut ustar_${tlabel}.grd -GFricVel_sub.grd -R${xmin}/${xmax}/${ymin}/${ymax} 2> /dev/null
#     ${GMTpre[GMTv]} grdcut windspeed_${tlabel}.grd -Gws_sub.grd -R${xmin}/${xmax}/${ymin}/${ymax} 2> /dev/null
#     ${GMTpre[GMTv]} grdcut u10_${tlabel}.grd -Gu10_sub.grd -R${xmin}/${xmax}/${ymin}/${ymax} 2> /dev/null
#     ${GMTpre[GMTv]} grdcut v10_${tlabel}.grd -Gv10_sub.grd -R${xmin}/${xmax}/${ymin}/${ymax} 2> /dev/null
#
#     ${GMTpre[GMTv]} pscoast $AREA $PROJg $BASE $DETAIL $COAST -K  > temp.ps
#     ${GMTpre[GMTv]} grdimage SnowDepth_sub.grd $PROJp  -Csnwdpth.cpt -O -K >> temp.ps
#     #${GMTpre[GMTv]} grdcontour FricVel_sub.grd $PROJp -C0.5 -W2/255/255/0 -O -K >> temp.ps
#     ${GMTpre[GMTv]} grdcontour ws_sub.grd $PROJp -C10.0 -W2/255/0/0 -O -K >> temp.ps
#     ${GMTpre[GMTv]} grdcontour ws_sub.grd $PROJp -C20.0 -W6/255/0/0 -O -K >> temp.ps
#     ${GMTpre[GMTv]} psxy /home/ash3d/bin/Resuspension_Alert/Katmai_VTTS_deposit_outline_LonLat.csv   $AREA $PROJg -P -M -K -O -W2/255/255/0 -V >> temp.ps
#     ${GMTpre[GMTv]} psxy /home/ash3d/bin/Resuspension_Alert/Katmai_H_deposit_outline_Sat_LonLat.csv  $AREA $PROJg -P -M -K -O -W6/0/255/0 -V >> temp.ps
#     ${GMTpre[GMTv]} pscoast $AREA $PROJg $DETAIL $COAST -O -K >> temp.ps
#     ${GMTpre[GMTv]} grdvector u10_sub.grd v10_sub.grd $PROJp -Cws.cpt -S20.0 -W2 -O -K >> temp.ps
#     ${GMTpre[GMTv]} psscale -D1.2i/-0.05i/2i/0.15ih -Cws.cpt -B5f5/:"Low-level Wind Speed (m/s)": -O -K >> temp.ps
#     ${GMTpre[GMTv]} psscale -D1.2i/-0.5i/2i/0.15ih -Csnwdpth.cpt -B0.01f0.01/:"Snow Depth (m)": -O -K >> temp.ps
#     ${GMTpre[GMTv]} psbasemap $AREA $PROJg $BASE -O -K >> temp.ps
#     echo $vln $vlt '1.0' | ${GMTpre[GMTv]} psxy $AREA $PROJg -St0.1i -Gred -Wthinnest -O -K >> temp.ps
#     ${GMTpre[GMTv]} pslegend $AREA $PROJg $BASE -G255 -F -D-155.9/59.4/5.0i/0.8i/BL -O << EOF >> temp.ps
#C black
#H 12 1 Low-level Wind Speed (NAM91) $FC_day + $tlabel
#D 0.05i 1p
#N 2
#V 0.0 1p
#S 0.1i - 0.15i - 6/255/255/0 0.3i VTTS deposit
#S 0.1i - 0.15i - 2/255/0/0   0.3i Surface gusts >10m/s
#S 0.1i - 0.15i - 6/0/255/0   0.3i UnitH deposit
#S 0.1i - 0.15i - 6/255/0/0   0.3i Surface gusts >20m/s
#EOF
#     ps2raster -A -Te temp.ps
#     ps2epsi temp.ps temp.eps
#     epstopdf temp.eps
#     convert temp.pdf -background white -flatten ${outfile}
#     rm temp.* *.grd
#     #rm ${infile}
#   fi
# fi
#done
#
#gifsicle --delay=25 --colors 256 `ls Kat*.gif` --loopcount=0 -o Animation_Katmai_Weather.gif

#rm ${ResuspHTTP}/Katmai*.gif
#cp *.gif ${ResuspHTTP}/

#rm *cpt

loc_end_date=`date`
echo "-----------------------------------------------------------"
echo "Finished Resusp3_MakePlots.sh at ${loc_end_date}"
echo "-----------------------------------------------------------"

