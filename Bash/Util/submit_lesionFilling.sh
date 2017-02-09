#!/bin/bash
# condor script for lesion filler
# We fill in T1 hypinitensities to avoid errors in
# calulating the template warps with ants.
# There are four possible cases
# 1. wmh + aseg : use both to reate mask for lesion filler
# 2. wmh        : use only wmh for creating mask
# 3. aseg       : use only aseg for creatig mask
# 4. none       : ignore


imDir=/home/torgil/Projects/HUNT/WorkData
startDir=`pwd`
t1Name=brain_t1w.nii.gz
wmhMask=wmh_t1.nii.gz # this is the wml interpolated to subjects T1 image

# first make a list of all studies with a wmh mask 
# note the braces () which makes output a array
#wmhFiles=(`find $imDir -type f -name $wmhMask`)

# loop over all dirs in imDir, note the /*/ which ensures
# that we only list dirs 
studyDirs=(`ls -d $imDir/*/`) 

startDir=`pwd`
jobScript=/home/torgil/Projects/HUNT/ProcessingScripts/Bash/Util/lesion_filler.sh
# set up directory for condor jobs
CONDORDIR=condor_`date +%Y%m%d_%H%M%S`
mkdir $CONDORDIR

i=1
for thisStudy in ${studyDirs[@]}; do
    # condor stuff
    condorJobFile=$CONDORDIR/job_$i.condor
    logfile=$CONDORDIR/job_$i.log
    outfile=$CONDORDIR/job_$i.output
    errfile=$CONDORDIR/job_$i.err

    # set vars
    flairDir=${thisStudy}/FLAIR
    flairSpmDir=${flairDir}/spm
    if [ -d "$flairDir" ] &&  [ -d "$flairSpmDir"  ]; then
	wmhFile=${flairSpmDir}/${wmhMask}
    else
	wmhFile=false
    fi

    
    # find the warps under T1_1 or T1_2
    t1AntsDir=''
    if [ -d ${thisStudy}/T1_1/ants ]; then
	t1Dir=${thisStudy}/T1_1
    elif [ -d ${thisStudy}/T1_2/ants ]; then
	    t1Dir=${thisStudy}/T1_2	    
    else
       continue
    fi
    t1AntsDir=${t1Dir}/ants
    t1File=${t1Dir}/${t1Name}
    wmMask=${t1Dir}/c2t1w.nii.gz
    # if the wm mask is missing we skip the subject (unlikely)
    if [ ! -e "$wmMask" ];  then
       continue
    fi

    # check if we have a aseg file
    asegFile=${t1AntsDir}/fsAseg.nii.gz
    if [ ! -e "$asegFile" ];  then
	asegFile=false
    fi

    
    t1Filled=${t1AntsDir}/brain_lesionFilled.nii.gz

    # configure and submit condor job
    # arguments 
    jobArgs="-d $t1AntsDir -w $wmhFile -t $t1File -f $t1Filled -m $wmMask -a $asegFile"
    echo  Universe = vanilla > $condorJobFile
    echo  Executable = $jobScript >> $condorJobFile
    echo  Arguments ="$jobArgs" >> $condorJobFile
    echo  Log = $logfile >> $condorJobFile
    echo  Output = $outfile >> $condorJobFile
    echo  Error = $errfile >> $condorJobFile
    echo  Queue >> $condorJobFile
    ((i++))
    # submit current job
    condor_submit $condorJobFile
    sleep 1
done

condor_q
