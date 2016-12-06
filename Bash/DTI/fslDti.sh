#!/bin/bash

## TODO :: make logging file

# processing steps
# 1. eddy_correct
# 2. rotate_bvec
# 3. brainmask
# 4. dti_fit

function usage {
  echo "Standard dti processing with FSL pipline"
  echo "Usage:  "
  echo "$0  -i dti_image_stack  -v bvec_file -b bval_file -o base_name_of_dti_output"
}

function chkFile () {
    if [ ! -e $1 ]
    then
	echo "Error file $1 is missing"
	exit 2
    fi
}

function doCmd () {
    cmd="$1"
    logging="$2"
    logfile="$3"    
    if [ "$logging" = true ]; then
	echo $cmd  >> $logfile
	eval "$cmd" >> $logfile
    else
	echo $cmd 
	eval "$cmd" 
    fi
}


# test for empty args
if [ $# -eq 0 ] 
    then
      usage
      exit 2
fi

# parse args
while getopts "i:v:b:o:" flag
do
  case "$flag" in
    i)
      dtiStack=$OPTARG
      ;;
    v)
      bvec=$OPTARG
      ;;
    b)
      bval=$OPTARG
      ;;
    o)
      ostem=$OPTARG
      ;;    
    h|?)
      echo $flag
      usage
      exit 2
      ;;
  esac
done

## main
logging=true
imExt=.nii.gz
initDir=`pwd`
dtiDir=$(dirname "${dtiStack}")
####################
# test inputs 
####################
chkFile $dtiStack
chkFile $bvec
chkFile $bval
####################
# set up logfile
####################
if [ "$logging" = true ]; then
    logfile=${dtiDir}/dti_log.txt
    echo "************************"   >> $logfile 
    date  >> $logfile
    echo "DTI dir = $dtiDir" >> $logfile
    echo "************************"  >> $logfile 
fi

####################
# 1. eddy_correct
####################
cd $dtiDir
# ref = 0 < make optinal argument!
dtiStackName=$(basename "${dtiStack}" $imExt)
# can also use:
# dtiStackName=`remove_ext ${dtiStack)`
correctedStack="corr_"${dtiStackName}
interp="trilinear"  # < make optinal argument!
cmd="eddy_correct $dtiStackName $correctedStack 0 $interp" 
doCmd "$cmd" "$logging" "$logfile"

####################
# 2. rotate bvecs
###################
bvecName=$(basename "${bvec}")
eccLog="corr_dti.ecclog"
corrBvec="corr_"${bvecName}
cmd="my_fdt_rotate_bvecs.sh $bvecName $corrBvec $eccLog"
doCmd "$cmd" "$logging" "$logfile"

####################
# 3. brainmask
###################
#bet $correctedStack b0_brain -R -f 0.3 -m
#imrm b0_brain
#mv b0_brain_mask${imExt} brainmask${imExt}
# the mask will always be named outputFile_mask
mask=${dtiDir}/dti_mask${imExt}
cmd="mkDtiBrainmask.sh -i $dtiStack -b $bval -m $mask" 
doCmd "$cmd" "$logging" "$logfile"

####################
# 4. dti_fit
###################
cmd="dtifit -k $correctedStack -o $ostem -m $mask -r $corrBvec -b $bval --sse -w"
doCmd "$cmd" "$logging" "$logfile"

## end
cd $initDir

if [ "$logging" = true ]; then
    logfile=${dtiDir}/dti_log.txt
    echo "done." >> $logfile 
    date  >> $logfile
    echo "************************"   >> $logfile 
    echo "************************"  >> $logfile 
fi

