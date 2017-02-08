#!/bin/bash
# condor script for lesion filler


imDir=/home/torgil/Projects/HUNT/Testing/wmh_mask/data/
startDir=`pwd`
t1Name=brain_t1w.nii.gz
wmhMask=wmh_t1.nii.gz # this is the wml interpolated to subjects T1 image

# first make a list of all studies with a wmh mask 
# note the braces () which makes output a array
wmhFiles=(`find $imDir -type f -name $wmhMask`)

startDir=`pwd`

jobScript=/home/torgil/Projects/HUNT/ProcessingScripts/Bash/Util/lesion_filler.sh
CONDORDIR=condor_`date +%Y%m%d_%H%M%S`
mkdir $CONDORDIR

i=1
for wmh in ${wmhFiles[@]}; do
    # condor stuff
    condorJobFile=$CONDORDIR/job_$i.condor
    logfile=$CONDORDIR/job_$i.log
    outfile=$CONDORDIR/job_$i.output
    errfile=$CONDORDIR/job_$i.err
    
    # set vars
    flairSpmDir=`dirname $wmh`
    flairDir=`dirname $flairSpmDir`
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
    wmMask=${t1Dir}/c2t1w.nii.gz 
    t1Filled=${t1AntsDir}/brain_lesionFilled.nii.gz

    # configure and submit condor job
    # arguments 
    jobArgs="-d $t1AntsDir -w $wmh -t $t1File -f $t1Filled -m $wmMask"
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
