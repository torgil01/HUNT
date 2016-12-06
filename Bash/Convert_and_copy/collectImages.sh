#!/bin/bash
# collect image files and move to some location

studyDir=~/Projects/HUNT/mkTemplate
seriesDir=`find $studyDir -name T1_1`
fileName=brain_t1w.nii.gz
destDir=~/Projects/HUNT/mkTemplate/buildTemplate
for series in ${seriesDir[@]}; do
    d1=$(dirname "${series}")
    id=$(basename "${d1}")
    #9410000013459
    newFileName=t1w_${id:7:7}.nii.gz
    echo cp $series/$fileName $destDir/$newFileName
    cp $series/$fileName $destDir/$newFileName
done
