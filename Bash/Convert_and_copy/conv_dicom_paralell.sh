#!/bin/bash

# takes too long sequentially

OrigDataDir=/home/torgil/Projects/HUNT/SourceData/OriginalData/
niiRawDir=/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii

# done
# hunt_2008_07
# hunt_2009_01 \
# hunt_2009_04 \
# hunt_2009_10 \

dataDirs=(hunt_2009_12 \
	  hunt_2008_10 \
	  hunt_2009_02 \
	  hunt_2009_08 \
	  hunt_2009_11 \	  
	  hunt_2008_03 \
	  missing_fikk_juni_10)


dirName=${dataDirs[1]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName &

dirName=${dataDirs[2]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName &

dirName=${dataDirs[3]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName &

dirName=${dataDirs[4]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName &

dirName=${dataDirs[5]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName &

dirName=${dataDirs[6]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName &

dirName=${dataDirs[7]}
mkdir $niiRawDir/$dirName
dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName 

## manual check for this one

dcm_conv.sh -m hunt -D $OrigDataDir/10_missing_fikk_2013 -o $niiRawDir/10_missing_fikk_2013
