#!/bin/bash
## coregistration only works best! no need for ants!
# warp flair images to t1
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=2

#imDir=/home/torgil/Projects/HUNT/WorkData
imDir=/home/torgil/Projects/HUNT/DTI_testing/wml
startDir=`pwd`
t1Name=brain_t1w.nii.gz
wmlName=wml.nii.gz
flairFileName=flair.nii.gz
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz

# first make a list of all studies with WMH seg files
# note the braces () which makes output a array
flairFiles=(`find $imDir -type f -name $flairFileName`)

for fl in ${flairFiles[@]}; do
    # set up ants subdirectory under flair dir if not there 
    flairDir=`dirname $fl`
    cd $flairDir
    # check if there is a wml, if not continue 
    wmlFile=${flairDir}/${wmlName}
    if [ ! -f $wmlFile ]; then
	echo "No wml $wmlFile"
	continue
    fi

    if [ ! -d "ants" ]; then
	mkdir ants	
    fi
    flairAntsDir=${flairDir}/ants
    logfile=${flairAntsDir}/antsRegistration-log.txt
    cd ants
    
    # find the warps under T1_1 or T1_2
    studyDirName=`dirname $flairDir`
    ID=`basename ${studyDirName}`
    t1AntsDir=''
    if [ -d $studyDirName/T1_1/ants ]; then
	t1Dir=$studyDirName/T1_1
    elif [ -d $studyDirName/T1_2/ants ]; then
	    t1Dir=$studyDirName/T1_2	    
    else
       continue
    fi
    t1AntsDir=${t1Dir}/ants
    t1File=${t1Dir}/${t1Name}
    t1TotemplateWarp=${t1AntsDir}/brain_t1w_1Warp.nii.gz
    t1TotemplateAffine=${t1AntsDir}/brain_t1w_0GenericAffine.mat
    

    # fix flair header
    # The original flair header contains two qform matrices, the original, and
    # the FLAIR -> T1 coreg. ANTS appear to only read the first, and therefore does
    # not "see" that the FALIR image is coregistered to the T1. 

    flFix=${flairDir}/flair-fix.nii.gz
    CopyImageHeaderInformation $wmlFile $fl $flFix 1 1 1
    


    # warp flair > t1_brain
    t1Warp=flair_to_t1
    antsRegistrationSyNQuick.sh -t r\
     			    -d 3\
     			    -f $t1File\
     			    -m $flFix\
     			    -n $ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS\
     			    -o $t1Warp

    # > $logfile

    # rename the warped file to wflair_t1
    mv flair_to_t1Warped.nii.gz wflair_t1.nii.gz
    rm flair_to_t1InverseWarped.nii.gz 
    
    # warp the WMH map    
    inFile=$wmlFile
    outFile=${flairAntsDir}/wwml_t1.nii.gz
    antsApplyTransforms -d 3 -i ${inFile} \
    			    -r wflair_t1.nii.gz \
    			    -o ${outFile} \
     			    -t ${t1Warp}0GenericAffine.mat \
    			    -n NearestNeighbor \
    			    -v 1 >> $logfile

done

