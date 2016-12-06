#!/bin/bash
# apply wml warps using T1-warpfields
# each warp take appx 6s cpu time so there is no need to
# run it in paralell 


imDir=/home/torgil/Projects/HUNT/WorkData/
#imDir=/home/torgil/Projects/HUNT/Testing2/
flairFileName=flair.nii.gz
wmlFileName=wml.nii.gz

startDir=`pwd`
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz

# first make a list of all FLAIR dirs with WML 
# note the braces () which makes output a array
wmlFiles=(`find $imDir -type f -name $wmlFileName`)

for f in ${wmlFiles[@]}; do
    # set up a ants subdirectory under the flair dir
    dirName=`dirname $f`
    cd $dirName
    if [ ! -d "ants" ]; then
	mkdir ants
    fi

    # find the warps under T1_1 or T1_2
    studyDirName=`dirname $dirName`
    ID=`basename ${studyDirName}`
    t1AntsDir=''
    if [ -d $studyDirName/T1_1/ants ]; then
	t1AntsDir=$studyDirName/T1_1/ants
    else
	if [ -d $studyDirName/T1_2/ants ]; then
	    t1AntsDir=$studyDirName/T1_2/ants
	else
	    exit -1
	fi
    fi
    affFile=${t1AntsDir}/brain_t1w_0GenericAffine.mat
    warpFile=${t1AntsDir}/brain_t1w_1Warp.nii.gz
    
    # set up input args for call to ants_warp.sh
    INPUT=$f
    OUTPUT=${dirName}/ants/w_wml.nii.gz
    REF=$TEMPLATE
    INTER=NearestNeighbor
    WARP=$warpFile
    AFF=$affFile

    # call
    echo $ID
    ants_warp.sh $INPUT $OUTPUT  $REF $WARP $AFF $INTER 
        
done





