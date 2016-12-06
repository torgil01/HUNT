#!/bin/bash
# 02.02.16 This script was used for converting the DICOM data to nii.
# 

OrigDataDir=/home/torgil/Projects/HUNT/SourceData/OriginalData/
niiRawDir=/home/torgil/Projects/HUNT/SourceData/NiiRaw/

dataDirs=(10_missing_fikk_2013 \
	  hunt_2008_07 \
	  hunt_2009_01 \
	  hunt_2009_04 \
	  hunt_2009_10 \
	  hunt_2009_12 \
	  hunt_2008_10 \
	  hunt_2009_02 \
	  hunt_2009_08 \
	  hunt_2009_11 \	  
	  missing_fikk_juni_10)



for dirName in ${dataDirs[@]}; do
    mkdir $niiRawDir/$dirName
    dcm_conv.sh -m hunt -D $OrigDataDir/$dirName -o $niiRawDir/$dirName
done



#  10_missing_fikk_2013
# feilnr_tomme_etc  % skip
# hunt_2008_07
# hunt_2009_01
# hunt_2009_04
# hunt_2009_10
# hunt_2009_12
# Diverse           % skip
# hunt_2008_03      % done
# hunt_2008_10
# hunt_2009_02
# hunt_2009_08
# hunt_2009_11
# missing_fikk_juni_10
