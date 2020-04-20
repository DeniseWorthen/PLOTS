#! /bin/csh -f

set outFile = "test-out"
echo $outFile
set varnames="(/"aice", "hi", "hs", "albsni"/)"
echo $varnames

ncl inFile=\"{$outFile}.tmp.nc\" outFile=\"{$outFile}.nc\" varnames=\"{$varnames}\" testx.ncl
