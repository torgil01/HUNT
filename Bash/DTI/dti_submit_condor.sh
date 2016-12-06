#!/bin/bash 
# Submit dti scripts to condor
# 

# NB! if condor is nit running do:
# sudo service condor start 

baseDir=/home/torgil/Projects/HUNT/WorkData

startDir=`pwd`
CONDORDIR=condor_dti_`date +%Y%m%d_%H%M%S`
mkdir $CONDORDIR
jobScript=/home/torgil/Projects/HUNT/ProcessingScripts/Bash/fslDti.sh

i=1
for dirs in ${baseDir}/*
do
    dtiDir=${dirs}/DTI
    if [ -d "$dtiDir" ]
    then
	# condor variables
	condorJobFile=$CONDORDIR/job_$i.condor
	logfile=$CONDORDIR/job_$i.log
	outfile=$CONDORDIR/job_$i.output
	errfile=$CONDORDIR/job_$i.err
	# set up variables for job
	in=${dtiDir}/dti.nii.gz
	out=${dtiDir}/dt
	bval=${dtiDir}/dti.bval
	bvec=${dtiDir}/dti.bvec
	# construct condor jobfile
	echo  Universe = vanilla > $condorJobFile
	echo  Executable = $jobScript >> $condorJobFile
	echo  Arguments = "-i $in -v $bvec -b $bval -o $out" >> $condorJobFile
	echo  getenv = True >> $condorJobFile
        echo  Log = $logfile >> $condorJobFile
	echo  Output = $outfile >> $condorJobFile
	echo  Error = $errfile >> $condorJobFile
	echo  Queue >> $condorJobFile
	((i++))
	# submit current job
	condor_submit $condorJobFile
	sleep 1
    fi           
done
condor_q

