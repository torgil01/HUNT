#/bin/bash
# 11.02.16 The original dciom -> nii converter 
# used dcm2niix. There were problems particulary with the FLAIR
# images, and dcm2nii appears to work better; 

OrigDataDir=/home/torgil/Projects/HUNT/SourceData/OriginalData/
niiRawDir=/home/torgil/Projects/HUNT/SourceData/NiiRaw_dcm2nii

dataDirs=(hunt_2008_07 \
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



#  10_missing_fikk_2013  ** skip
# feilnr_tomme_etc  % skip
# hunt_2008_07
# hunt_2009_01
# hunt_2009_04
# hunt_2009_10
# hunt_2009_12
# Diverse           % skip
# hunt_2008_03     
# hunt_2008_10
# hunt_2009_02
# hunt_2009_08
# hunt_2009_11
# missing_fikk_juni_10
