#!/bin/bash
# Submit ants jobs to condor
# This is a more flexible version of the original "ants_submit.sh" script that was used for
# computing the original warps to the N32 template. This scrip allows for warping arbitary
# images to a template. 

# Usage: ants_submit.sh [-c csv-file] -d ImageDirectory -n file-name-for-warp

# parse args
while getopts "hc:d:n:" flag
do
  case "$flag" in
    d)
	imDir=$OPTARG	
      ;;
    c)
	csv=$OPTARG
      ;;
    n)
	inputFileName=$OPTARG
      ;;
    h|?)    
      echo Unknown input flag $flag
      exit 2
      ;;
  esac
done




if [ -e "$csv" ]; then    
    # NOTE! the file encoding for the CSV file cases trouble with
    # DOS newlines. either load csv in emacs and save with linux encoding or
    # use "dos2unix"
    i=0
    while IFS=, read col1 col2 col3
    do
	imFiles[$i]=${col2}/${col3//\"}/$inputFileName
	i=$((i+1))
    done < $csv
else
    # Instad of using a CSV file we search $imDir for all files matching 
    imFiles=(`find "$imDir" -type f -name $inputFileName`)
fi
    
CONDORDIR=condor_`date +%Y%m%d_%H%M%S`
mkdir $CONDORDIR
MASK=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/brainmask.nii.gz
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz
jobScript=/home/torgil/Projects/HUNT/ProcessingScripts/Bash/ants/ants_runner.sh

i=1
for f in ${imFiles[@]}; do
    condorJobFile=$CONDORDIR/job_$i.condor
    logfile=$CONDORDIR/job_$i.log
    outfile=$CONDORDIR/job_$i.output
    errfile=$CONDORDIR/job_$i.err
    # name for warps 
    fn=`basename $f .nii.gz`
    OUT=${fn}_
    # coondor job settings
    echo  Universe = vanilla > $condorJobFile
    echo  Executable = $jobScript >> $condorJobFile
    echo  Arguments = "$TEMPLATE $MASK $f $OUT" >> $condorJobFile
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




