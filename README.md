# Code fragments related to testing and configuring MITgcm pkg/nf90io

MITgcm pkg/nf90io requires several tools to be in place and installed
correctly. The nf90io uses parallel netCDF-4. This has dependencies
on consistently installed HDF-5, MPI and compiler versions as well
as optional dependencies on pnetcdf.

The nf90io_pregenmake.sh script does some checks to try and detect 
is a consistent set of netcdf, hdf, mpi and optionally pnetcdf -
all build against the same compiler is present and appears
to be functioning correctly.

The script produces shell code fragements to set MITgcm build
options CC, FC, INCLUDES and LIBS. These need to be merged (somehow?)
with other options in tools/build_options/XXXXX.
