#!/bin/bash
# warp GM/WM prob maps with ants 
# Note that there may be more than 1 set of prob maps
# since some scans have two T1
# we need only one, so we find the T1 dir with the "ants" subdir
# this would be the "best T1"

imDir=/home/torgil/Projects/HUNT/WorkData/
#imDir=/home/torgil/Projects/HUNT/Testing2/
inputFileName=c1t1w.nii.gz

startDir=`pwd`
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz

# first make a list of all input files to be warped
# note the braces () which makes output a array
#cd $imDir
studyDirs=(`find $imDir -maxdepth 1 -mindepth 1  -type d`)
echo $studyDirs
for d in ${studyDirs[@]}; do
    # set up a ants subdirectory where input file reside
    studyDirName=$d
    echo $studyDirName

    # find the warps under T1_1 or T1_2
    ID=`basename ${studyDirName}`
    t1AntsDir=''
    if [ -d ${studyDirName}/T1_1/ants ]; then
	t1AntsDir=${studyDirName}/T1_1/ants
    else
	if [ -d ${studyDirName}/T1_2/ants ]; then
	    t1AntsDir=${studyDirName}/T1_2/ants
	else
	    # there is probably a empty dir here
	    continue
	fi
    fi
    echo $t1AntsDir
    affFile=${t1AntsDir}/brain_t1w_0GenericAffine.mat
    warpFile=${t1AntsDir}/brain_t1w_1Warp.nii.gz
    t1Dir=`dirname ${t1AntsDir}`    
    INPUT=${t1Dir}/${inputFileName}
    echo $INPUT
    if [ -f $INPUT ]; then
	# set up input args for call to ants_warp.sh
	OUTPUT=${t1AntsDir}/w_${inputFileName}
	REF=$TEMPLATE
	INTER=Linear
	WARP=$warpFile
	AFF=$affFile	
	echo $ID
	echo ants_warp.sh $INPUT $OUTPUT  $REF $WARP $AFF $INTER 
	ants_warp.sh $INPUT $OUTPUT  $REF $WARP $AFF $INTER 
    fi
done
cd $startDir




