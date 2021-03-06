#!/bin/bash
# warp GM/WM prob maps with ants 
# Note that there may be more than 1 set of prob maps
# since some scans have two T1
# we need only one, so we find the T1 dir with the "ants" subdir
# this would be the "best T1"

imDir=/home/torgil/Projects/HUNT/WorkData/
#imDir=/home/torgil/Projects/HUNT/Testing2/
inputFileName=c2t1w.nii.gz

startDir=`pwd`
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz

# first make a list of all input files to be warped
# note the braces () which makes output a array
#cd $imDir
studyDirs=(`find $imDir -maxdepth 1 -mindepth 1  -type d`)
echo $studyDirs
for d in ${studyDirs[@]}; do
    echo $d
done
