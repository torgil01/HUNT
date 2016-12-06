#!/bin/bash
# script for running eddy

function usage {
    echo "FSL eddy wrapper"
    echo "see http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/EDDY"
    echo "Usage:  "
    echo "$0  -i dtiStack -m brainmask -b bval -v bvec -e echoSpacing -o correctedDti"
}

# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
# defaults
# number of openMP cores 
nCores=12

while getopts "i:m:b:v:e:o:" flag
do
  case "$flag" in
    i)
      dtiStack=$OPTARG
      ;;
    m)
      mask=$OPTARG
      ;;
    b)
      bval=$OPTARG
      ;;
    v)
      bvec=$OPTARG
      ;;
    e)
     echoSpacing=$OPTARG
      ;;   
    o)
      corrDti=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

## main
export OMP_NUM_THREADS=$nCores # 
# get number of volumes in dti stack 
nvol=$(fslnvols $dtiStack)
# remove possible extenstion on DTI output  file, to avoid strange filenames
corrDti=$(remove_ext ${corrDti})
# get directory for dti stack and cd there
dtiDir=$(dirname "${dtiStack}")
cd $dtiDir

# mk index file
indx=""
for ((i=1; i<=${nvol}; i+=1)); do indx="$indx 1"; done
echo $indx > index.txt
# mk param file
if [ -e "acqparams.txt" ]; then rm acqparams.txt ; fi
for ((i=1; i<=${nvol}; i+=1)); do
    printf "0 1 0 ${echoSpacing}\n" >> acqparams.txt
done

# note that the repol parameters is only available for the openMP version
eddy_openmp --imain=${dtiStack} --mask=${mask} --acqp=acqparams.txt --index=index.txt --bvecs=${bvec} --bvals=${bval} --repol --out=${corrDti}
