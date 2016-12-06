#!/bin/bash
# check the quality of ANTS warps to template by measuring image similarity


imDir=/home/torgil/Projects/HUNT/WorkData
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz
fileName=brain_t1w_Warped.nii.gz


# orig find cmd
#files=(`find $imDir -type f -name $fileName`)

# some extra files 
files=(`find $imDir -type f -name $fileName -newermt "Mar 29 17:00"`)

for f in ${files[@]}; do
    #  Metric 0 - MeanSquareDifference, 1 - Cross-Correlation, 2-Mutual Information , 3-SMI
    #echo ${f} ";" >> logfile.txt
    MeasureImageSimilarity 3 1 ${f} $TEMPLATE >> logfile.txt
done
