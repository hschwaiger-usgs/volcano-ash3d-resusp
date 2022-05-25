###############################################################################
#  Makefile for Ash3d_webtools
#
#    User-specified flags are in this top block
#
###############################################################################

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

#      Sequence of commands:
#      "make"  compiles the Ash3d executable
#      "make all" builds the executables and copies to bin
#      "make install" copies the scripts and files to the install location
#                        e.g. /opt/USGS/Ash3d
#
#  SYSTEM specifies which compiler to use
#    Current available options are:
#      gfortran , ifort
#    This variable cannot be left blank
SYSTEM = gfortran
#
#  RUN specifies which collection of compilation flags that should be run
#    Current available options are:
#      DEBUG : includes debugging info and issues warnings
#      PROF  : includes profiling flags with some optimization
#      OPT   : includes optimizations flags for fastest runtime
#      OMPOPT: includes optimizations flags for fastest runtime and OpenMP directives
#              To run, enter: env OMP_NUM_THREADS=4 Ash3d input_file.inp
#    This variable cannot be left blank
RUN = OPT

# This is the location of the USGS libraries and include files
USGSROOT=/opt/USGS
INSTALLDIR=/opt/USGS/Ash3d

#
###############################################################################

###############################################################################
#####  END OF USER SPECIFIED FLAGS  ###########################################
###############################################################################



###############################################################################
##########  GNU Fortran Compiler  #############################################
ifeq ($(SYSTEM), gfortran)

    FCHOME=/usr
    FC=/usr/bin/gfortran

    COMPINC = -I$(FCHOME)/include -I$(FCHOME)/lib64/gfortran/modules
    COMPLIBS = -L$(FCHOME)/lib -L$(FCHOME)/lib64

    LIBS = $(COMPLIBS) $(USGSLIBDIR) $(USGSINC) $(COMPINC) $(USGSLIB) $(DATALIBS)

# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS =  -O0 -g3 -Wall -fbounds-check -pedantic -fbacktrace -fimplicit-none -Wunderflow -Wuninitialized -ffpe-trap=invalid,zero,overflow -fdefault-real-8
    ASH3DEXEC=Ash3d_debug
endif
ifeq ($(RUN), DEBUGOMP)
    FFLAGS =  -g3 -pg -Wall -fbounds-check -pedantic -fimplicit-none -Wunderflow -Wuninitialized -Wmaybe-uninitialized -ffpe-trap=invalid,zero,overflow -fdefault-real-8 -fopenmp -lgomp
    ASH3DEXEC=Ash3d_debugOMP
endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g -pg -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
    ASH3DEXEC=Ash3d_prof
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -w -fno-math-errno -funsafe-math-optimizations -fno-trapping-math -fno-signaling-nans -fcx-limited-range -fno-rounding-math -fdefault-real-8
    ASH3DEXEC=Ash3d
endif
ifeq ($(RUN), OMPOPT)
    FFLAGS = -O3 -w -ffast-math -fdefault-real-8 -fopenmp -lgomp
    ASH3DEXEC=Ash3d_omp
endif

      # Preprocessing flags
    FPPFLAGS =  -x f95-cpp-input $(VERBFPPFLAG)
      # Extra flags
    #EXFLAGS = -xf95
    EXFLAGS =
endif
###############################################################################
##########  Intel Fortran Compiler  #############################################
ifeq ($(SYSTEM), ifort)
    FCHOME = $(HOME)/intel
    FC = $(FCHOME)/bin/ifort
    COMPLIBS = -L$(FCHOME)/lib
    COMPINC = -I$(FCHOME)/include
    LIBS = $(COMPLIBS) $(DATALIBS) $(PROJLIBS) $(COMPINC) -llapack -lblas -lirc -limf
# Debugging flags
ifeq ($(RUN), DEBUG)
    FFLAGS = -g2 -pg -warn all -check all -real-size 64 -check uninit -traceback
    ASH3DEXEC=Ash3d_debug
endif
ifeq ($(RUN), DEBUGOMP)
    FFLAGS = -g2 -pg -warn all -check all -real-size 64 -check uninit -openmp
    ASH3DEXEC=Ash3d_debugOMP
endif
# Profiling flags
ifeq ($(RUN), PROF)
    FFLAGS = -g2 -pg
    ASH3DEXEC=Ash3d_prof
endif
# Production run flags
ifeq ($(RUN), OPT)
    FFLAGS = -O3 -ftz -w -ipo
    ASH3DEXEC=Ash3d
endif
ifeq ($(RUN), OMPOPT)
    FFLAGS = -O3 -ftz -w -ipo -openmp
    ASH3DEXEC=Ash3d_omp
endif

      # Preprocessing flags
    FPPFLAGS =  -fpp -Qoption,fpp $(VERBFPPFLAG) 
      # Extra flags
    EXFLAGS =
endif
###############################################################################

all: 
	echo "Nothing to be compiled"
	echo "Type 'make install' to install"

install:
	install -d $(INSTALLDIR)/bin/Resuspension_Alert
	install -d $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta
	install -m 644 Resuspension_Alert/Novarupta/Novarupta_VTTS_deposit_outline_LonLat.csv        $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta
	install -m 644 Resuspension_Alert/Novarupta/Novarupta_H_deposit_outline_Sat_LonLat.csv       $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta
	install -m 644 Resuspension_Alert/Novarupta/Novarupta_regionalH_FC_iwf13_3_LL_Block1.inp     $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta
	install -m 644 Resuspension_Alert/Novarupta/Novarupta_regionalH_FC_iwf13_3_LL_Block3-end.inp $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta
	install -m 755 Resuspension_Alert/plot_vprof                        $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/Resusp1_Extract_MetAlarmVars.sh   $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/Resusp2_CheckAlertConditions.sh   $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/Resusp3_MakePlots.sh              $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/Resusp4_runAsh3d.sh               $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/Resusp_TextWarning_Ash3d.py       $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/Resusp_TextWarning_Met.py         $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 Resuspension_Alert/test_points.sh                    $(INSTALLDIR)/bin/Resuspension_Alert/
	install -m 755 scripts/NAMMet_to_gif.sh                             $(INSTALLDIR)/bin/scripts/
	install -m 755 scripts/runAsh3d_resusp.sh                           $(INSTALLDIR)/bin/scripts/

uninstall:
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/plot_vprof
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Resusp1_Extract_MetAlarmVars.sh
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Resusp2_CheckAlertConditions.sh
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Resusp3_MakePlots.sh
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Resusp4_runAsh3d.sh
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Resusp_TextWarning_Ash3d.py
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Resusp_TextWarning_Met.py
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/test_points.sh
	rm -f $(INSTALLDIR)/bin/scripts/NAMMet_to_gif.sh
	rm -f $(INSTALLDIR)/bin/scripts/runAsh3d_resusp.sh
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta/Novorupta_regionalH_FC_iwf13_3_LL_Block3-end.inp
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta/Novarupta_H_deposit_outline_Sat_LonLat.csv
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta/Novarupta_regionalH_FC_iwf13_3_LL_Block1.inp
	rm -f $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta/Novarupta_VTTS_deposit_outline_LonLat.csv
	rmdir $(INSTALLDIR)/bin/Resuspension_Alert/Novarupta
	rmdir $(INSTALLDIR)/bin/Resuspension_Alert
	


