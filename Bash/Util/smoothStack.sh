#!/bin/bash 
# Smooth a large 4D image stack 
# 


splitVol=$1
mergeVol=$2

startDir=`pwd`
tempdir=/tmp/tmp_$RANDOM
mkdir $tempdir
cp $splitVol $tempdir/.
cd $tempdir

# split volume / remember zero-based indexing
fslsplit $splitVol vol_

# files are now called vol_0000 vol_0001 etc
files=(vol_*)
for f in ${files[@]}; do
    fslmaths $f -s 2 s_${f} -odt float
    rm $f
done

fslmerge -t $startDir/$mergeVol `imglob -oneperimage s_vol_*`
#echo merging `imglob -oneperimage vol_*`


cd $startDir
rm -rf $tempdir

}
