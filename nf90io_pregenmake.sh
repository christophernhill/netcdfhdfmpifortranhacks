#!/bin/bash
#
# Program for determining and testing MITgcm build options includes and lib settings for 
# pkg/nf90io parallel netcdf using F90 and MPI.
#
# set -ox

# pfe test setup(s)
#   module load comp-intel/2018.0.128 hdf5/1.8.18_mpt hdf4/4.2.12 mpi-hpe/mpt.2.17r4 netcdf/4.4.1.1_mpt
 
# engaging test setup(s)
#   module use /home/software/modulefiles/
#   module use ~jahn/software/modulefiles/
#   module add jahn/netcdf

# svante setup(s)
#   module load netcdf
#   ( fails - not a parallel netcdf)

# OpenHPC setup(s)
# 1.
# module load gnu
# module load mpich
# module load netcdf
# module load netcdf-fortran
# 2.
# module load gnu
# module load mvapich2
# module load netcdf
# module load netcdf-fortran
# 3.
# module load gnu
# module load openmpi
# module load netcdf
# module load netcdf-fortran
# 4.
# module load gnu7
# module load mvapich2
# module load netcdf
# module load netcdf-fortran


nc-config --all >& /dev/null
if [ x"$?" != x0 ]; then
 echo "# netcdf program \"nc-config\" not found, netcdf does not appear to be set up."
 echo "# You may need to add netcdf settings to your environment, including"
 echo "#  o search path, library path, help environment variables"
 echo "# On many systems the \"modules\" command can be used to set the environment."
 exit
fi

# Check if netCDF-4 is built
NC4=`nc-config --has-nc4`
if [ x"$NC4" != xyes ]; then
 echo "# netcdf found but it was not built with netCDF-4 support."
 echo "# nf90io requires netCDF-4 support."
 exit
fi

# Check if Fortran support is persent
NCF=`nc-config --has-fortran`
if [ x"$NCF" != xyes ]; then
 echo "# netcdf found but it does not have Fortran support active."
 echo "# nf90io requires netCDF with Fortran support."
 exit
fi

# Check if mpi commands are found
mpif77 -v >& /dev/null
if [ x"$?" != x0 ]; then
 echo "# MPI program \"mpif77\" not found, MPI does not appear to be fully set up in your environment."
 echo "# On many systems the \"modules\" command can be used to set the environment."
 exit
fi
mpif90 -v >& /dev/null
if [ x"$?" != x0 ]; then
 echo "# MPI program \"mpif90\" not found, MPI does not appear to be fully set up in your environment."
 echo "# On many systems the \"modules\" command can be used to set the environment."
 exit
fi
mpicc  -v >& /dev/null
if [ x"$?" != x0 ]; then
 echo "# MPI program \"mpicc\" not found, MPI does not appear to be fully set up in your environment."
 echo "# On many systems the \"modules\" command can be used to set the environment."
 exit
fi

# See if an MPI include directory can be found
MPICC=`which mpicc`
MPIRD=`dirname $MPICC`
MPIRROOT=`dirname $MPIRD`
MPIINC=''
if [ -d ${MPIRROOT}/include ]; then
 MPIINC='-I'${MPIRROOT}/include
fi

# See if an MPI lib directory can be found
MPICC=`which mpicc`
MPIRD=`dirname $MPICC`
MPIRROOT=`dirname $MPIRD`
MPILIB=''
if [ -d ${MPIRROOT}/lib ]; then
 MPILIB='-L'${MPIRROOT}/lib
fi


# Get environment variable for use in MITgcm build options
FINC=`nc-config --fflags`
INCLUDES=${FINC}
FLIB=`nc-config --flibs`
LIBS=`echo ${FLIB} | sed s'/-l[a-z]*//g'`

echo "# o Build options that are needed for MITgcm with nf90io"
echo "CC=mpicc"
echo "FC=mpif90"
echo "INCLUDES="$INCLUDES $MPIINC
echo "LIBS="$LIBS $MPILIB
echo "# ==================== "
echo " "

echo "# o Found the following preset NETCDF environment variables"
env | grep '^NETCDF' | awk '{print "# "$1}'
echo "# ==================== "
echo " "

echo "# o Found the following preset MPI environment variables"
env | grep '^MPI' | awk '{print "# "$1}'
echo "# ==================== "
echo " "

echo "# o Found the following preset HDF environment variables"
env | grep '^HDF' | awk '{print "# "$1}'
echo "# ==================== "
echo " "

# Now test whether it works
echo "# Testing settings with standalone parallel netcdf program"
mpif90 $INCLUDES $LIBS ../tools/maketests/f90tst_parallel.f90 -lnetcdff
mpirun -np 4 ./a.out
ncdump  f90tst_parallel.nc
