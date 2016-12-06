#!/bin/bash
# submit ants jobs to condor

imDir=/home/torgil/Projects/HUNT/WorkData/
#imDir=/home/torgil/Projects/HUNT/Testing2/
brainFileName=brain_t1w.nii.gz

# NOTE! the file encoding for the CSV file cases trouble with
# DOS newlines. either load csv in emacs and save with linux encoding or
# use "dos2unix"
i=0
while IFS=, read col1 col2 col3
do
    t1Files[$i]=${col2}/${col3//\"}/$brainFileName
    i=$((i+1))
done < $1


startDir=`pwd`
CONDORDIR=condor_`date +%Y%m%d_%H%M%S`
mkdir $CONDORDIR
MASK=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/brainmask.nii.gz
TEMPLATE=/home/torgil/Projects/HUNT/mkTemplate/FinalTemplates/N32.nii.gz
jobScript=/home/torgil/bin/ants_runner.sh

i=1
for f in ${t1Files[@]}; do
    condorJobFile=$CONDORDIR/job_$i.condor
    logfile=$CONDORDIR/job_$i.log
    outfile=$CONDORDIR/job_$i.output
    errfile=$CONDORDIR/job_$i.err
    # set up a ants subdirectory under the t1w folder
    # link t1-brain to this subfolder
    T1orig=$imDir/$f
    T1dir=`dirname $T1orig`
    cd $T1dir
    if [ ! -d "ants" ]; then
	mkdir ants
    fi
    T1W=$T1dir/ants/$brainFileName
    if [ ! -d "$T1W" ]; then
	 ln -s $T1orig $T1W
    fi
    fn=`basename $T1W .nii.gz`
    OUT=${fn}_
    cd $startDir
    
    echo  Universe = vanilla > $condorJobFile
    echo  Executable = $jobScript >> $condorJobFile
    echo  Arguments = "$TEMPLATE $MASK $T1W $OUT" >> $condorJobFile
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




