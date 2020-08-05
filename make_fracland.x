#!/bin/bash

set -x

ESMF_BINDIR="/glade/p/cesmdata/cseg/PROGS/esmf/8.1.0b23/mpiuni/intel/19.0.5/bin/binO/Linux.intel.64.mpiuni.default"

sorc="tx0.66v1_SCRIP_190314.nc"
svar="grid_imask"
dvar="land_frac"
dest="C96"
meth="conserve"

#${ESMF_BINDIR}/ESMF_Regrid -s ${sorc} -d ${dest}_mosaic.nc --src_var ${svar} --dst_var ${dvar} --dstdatafile ${dest}_grid 
${ESMF_BINDIR}/ESMF_RegridWeightGen -s ${sorc} -d ${dest}_mosaic.nc -m ${meth} --tilefile_path . --ignore_unmapped -w c96_mx066.nc 
